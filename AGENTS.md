# Dotfiles Repository Agent Guidelines

## Repository Structure
- Configurations are organized by tool/application
- Primary languages: Shell scripts (bash), Lua, configuration files
- Key directories: 
  - `bin/`: Custom scripts
  - `.config/`: Application configurations

## Development Guidelines
### Code Style
- Shell scripts: Use `shellcheck` for linting
- Lua scripts: Follow Lua 5.1+ conventions
- Indentation: 
  - Shell: 2 spaces
  - Lua: 2 spaces or tabs consistently
- Naming Conventions:
  - Scripts: lowercase-with-hyphens
  - Functions: snake_case
  - Variables: lowercase_with_underscores

### Testing
- No formal test framework detected
- Manual testing recommended:
  - Run scripts with `-x` flag for debugging
  - Test scripts in isolated environments
  - Validate configuration changes manually

### Commit Guidelines
- Descriptive commit messages
- Reference specific tool or configuration changed
- Avoid committing sensitive information

### Development Workflow
- Use `bin/` scripts for utility functions
- Modularize configurations
- Keep sensitive data out of version control

## Recommended Tools
- ShellCheck for bash script linting
- Lua language server for Lua script support
- Use `chmod +x` for executable scripts

## Notes
- Repository is personal dotfiles
- Configurations are environment-specific
- Always review before applying blindly