# Function to set TextMate as the default editor in the current shell
set_editor() {
    if ! grep -q "export EDITOR='mate -w'" ~/.bashrc; then
        echo "export EDITOR='mate -w'" >> ~/.bashrc
        echo "TextMate set as default editor in .bashrc"
    else
        echo "TextMate is already set as default editor in .bashrc"
    fi
}

# Function to set TextMate as the default editor in the dbt virtual environment
set_editor_in_dbt_env() {
    local dbt_env_path=$1

    if [ -d "$dbt_env_path" ]; then
        local activate_script="$dbt_env_path/bin/activate"
        
        if ! grep -q "export EDITOR='mate -w'" "$activate_script"; then
            echo "export EDITOR='mate -w'" >> "$activate_script"
            echo "TextMate set as default editor in $activate_script"
        else
            echo "TextMate is already set as default editor in $activate_script"
        fi
    else
        echo "The specified dbt virtual environment path does not exist."
    fi
}

# Check if TextMate command-line tool is installed
if ! command -v mate &> /dev/null; then
    echo "TextMate command-line tool 'mate' not found. Please install it first."
    exit 1
fi

# Set TextMate as the default editor in the shell
set_editor

# Reload the .bashrc file to apply changes
source ~/.bashrc

# Define the path to the dbt virtual environment
dbt_env_path="/Users/tanmay/my_dbt_projects/dbt-venv/dbt_snowflake_fetch_exercise"

# Set TextMate as the default editor in the dbt virtual environment
set_editor_in_dbt_env "$dbt_env_path"

echo "Configuration complete. Please restart your terminal or run 'source ~/.bashrc' to apply changes."
