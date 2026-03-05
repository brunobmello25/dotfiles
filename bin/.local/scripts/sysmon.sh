tmux new-session \; \
  split-window -h "sudo intel_gpu_top" \; \
  split-window -v "watch -n1 sensors" \; \
  select-pane -t 0 \; \
  send-keys "btop" Enter
