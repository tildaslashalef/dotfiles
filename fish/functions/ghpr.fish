function ghpr -d "Create a GitHub pull request with template"
    # Default template path
    set -l template_path " $HOME/.pr_template.md"
    
    # Check if template is specified as an argument
    if set -q argv[1]
        set template_path $argv[1]
    end
    
    # Ensure gh CLI is installed
    if not type -q gh
        echo "GitHub CLI (gh) is not installed. Please install it first."
        echo "brew install gh"
        return 1
    end
    
    # Create a PR using web interface with the template
    gh pr create --web --template $template_path
end 