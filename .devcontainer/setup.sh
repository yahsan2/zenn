#!/bin/bash
set -e

# Install Claude Code CLI
npm install -g @anthropic-ai/claude-code

# Add custom aliases
echo 'alias fork="code --open-url fork://open?path=/Users/yahsan2/Sites/working/personal/zenn"' >> ~/.bashrc

# Create terminal-notifier stub (macOS command not available in Linux container)
cat << 'EOF' | sudo tee /usr/local/bin/terminal-notifier > /dev/null
#!/bin/bash
while [[ $# -gt 0 ]]; do
  case $1 in
    -message) msg="$2"; shift 2;;
    -title) title="$2"; shift 2;;
    *) shift;;
  esac
done
echo "🔔 ${title}: ${msg}"
EOF
sudo chmod +x /usr/local/bin/terminal-notifier

# Create brew stub (macOS command not available in Linux container)
cat << 'EOF' | sudo tee /usr/local/bin/brew > /dev/null
#!/bin/bash
echo "⚠️ brew is not available in this container. Use apt instead."
EOF
sudo chmod +x /usr/local/bin/brew
