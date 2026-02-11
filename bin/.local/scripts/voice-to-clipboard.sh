#!/bin/bash
# ~/.local/bin/voice-to-clipboard.sh

set -e

# Configuration
WHISPER_MODEL="base"
LANGUAGE="pt"
TEMP_AUDIO="/tmp/voice_recording_$$.wav"
RECORDING_PID_FILE="/tmp/voice_recording_pid_$$"

# Function to show notifications
notify() {
    local title="$1"
    local message="$2"
    local urgency="${3:-normal}"
    notify-send -u "$urgency" "$title" "$message"
}

# Function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Check for required dependencies
check_dependencies() {
    local missing_deps=()
    
    if ! command_exists notify-send; then
        exit 1
    fi
    
    if ! command_exists arecord; then
        missing_deps+=("alsa-utils (for arecord)")
    fi
    
    if ! command_exists xclip; then
        missing_deps+=("xclip")
    fi
    
    if ! command_exists whisper; then
        missing_deps+=("openai-whisper")
    fi
    
    if ! command_exists zenity && ! command_exists yad; then
        missing_deps+=("zenity or yad (for GUI)")
    fi
    
    if [ ${#missing_deps[@]} -gt 0 ]; then
        local deps_list=$(printf '%s\n' "${missing_deps[@]}")
        notify "Voice-to-Clipboard: Missing Dependencies" \
               "Please install:\n${deps_list}\n\nFor whisper: pip install openai-whisper" \
               "critical"
        
        # Try to open a terminal with installation commands
        for term in alacritty kitty xterm; do
            if command_exists "$term"; then
                $term -e bash -c "echo 'Missing dependencies. Install with:'; \
                                   echo 'sudo pacman -S alsa-utils xclip zenity  # or apt/dnf'; \
                                   echo 'pip install --user openai-whisper'; \
                                   echo ''; \
                                   echo 'Press Enter to close...'; \
                                   read" &
                break
            fi
        done
        
        exit 1
    fi
}

# Function to stop recording
stop_recording() {
    if [ -f "$RECORDING_PID_FILE" ]; then
        local pid=$(cat "$RECORDING_PID_FILE")
        if kill -0 "$pid" 2>/dev/null; then
            kill "$pid" 2>/dev/null || true
        fi
        rm -f "$RECORDING_PID_FILE"
    fi
}

# Function to show recording window and record
record_audio() {
    # Start recording in background
    arecord -f cd -t wav "$TEMP_AUDIO" 2>/dev/null &
    local record_pid=$!
    echo "$record_pid" > "$RECORDING_PID_FILE"
    
    local user_choice
    
    # Show GUI window with two buttons
    if command_exists yad; then
        # YAD has better styling and multiple button support
        yad --title="Voice Recording" \
            --text="<big><b>🎤 Gravando...</b></big>\n\nFale agora. Quando terminar, clique em 'Parar e Transcrever'" \
            --button="Cancelar:1" \
            --button="Parar e Transcrever:0" \
            --width=350 \
            --height=150 \
            --center \
            --on-top \
            --borders=20 \
            2>/dev/null
        user_choice=$?
    else
        # Zenity with two buttons
        zenity --question \
               --title="Voice Recording" \
               --text="🎤 Gravando...\n\nFale agora. Quando terminar:" \
               --ok-label="Parar e Transcrever" \
               --cancel-label="Cancelar" \
               --width=350 \
               --height=150 \
               2>/dev/null
        user_choice=$?
    fi
    
    # Stop recording
    stop_recording
    
    # Check user choice
    # 0 = Stop & Transcribe, 1 = Cancel, 252 = Window closed (treat as cancel)
    if [ "$user_choice" -ne 0 ]; then
        notify "Voice-to-Clipboard" "Gravação cancelada" "normal"
        rm -f "$TEMP_AUDIO"
        return 1
    fi
    
    # Check if we got any audio
    if [ ! -f "$TEMP_AUDIO" ] || [ ! -s "$TEMP_AUDIO" ]; then
        notify "Voice-to-Clipboard: Erro" "Nenhum áudio gravado" "critical"
        return 1
    fi
    
    return 0
}

# Main function
main() {
    check_dependencies
    
    # Trap to cleanup on exit
    trap 'stop_recording; rm -f "$TEMP_AUDIO" "$RECORDING_PID_FILE"' EXIT INT TERM
    
    # Record audio with GUI
    if ! record_audio; then
        exit 0  # Exit cleanly if cancelled
    fi
    
    # Notify processing
    notify "Voice-to-Clipboard" "Processando áudio..." "normal"
    
    # Transcribe with whisper
    local transcription
    local output_file="/tmp/$(basename "$TEMP_AUDIO" .wav).txt"
    
    if ! whisper "$TEMP_AUDIO" \
                 --language "$LANGUAGE" \
                 --model "$WHISPER_MODEL" \
                 --output_format txt \
                 --output_dir /tmp 2>/dev/null; then
        notify "Voice-to-Clipboard: Erro" "Falha na transcrição" "critical"
        exit 1
    fi
    
    # Extract text from whisper output file
    if [ -f "$output_file" ]; then
        transcription=$(cat "$output_file")
        rm -f "$output_file"
    else
        notify "Voice-to-Clipboard: Erro" "Arquivo de transcrição não encontrado" "critical"
        exit 1
    fi
    
    # Clean up whitespace
    transcription=$(echo "$transcription" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
    
    if [ -z "$transcription" ]; then
        notify "Voice-to-Clipboard" "Nenhum texto detectado" "normal"
        exit 0
    fi
    
    # Copy to clipboard
    echo -n "$transcription" | xclip -selection clipboard
    
    # Notify success with preview
    local preview="${transcription:0:50}"
    if [ ${#transcription} -gt 50 ]; then
        preview="${preview}..."
    fi
    
    notify "Voice-to-Clipboard: Sucesso" "Copiado: ${preview}" "normal"
}

main "$@"