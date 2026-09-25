# Has to be declared in profile.d and not /etc/environment because Alpine
# declares the path in /etc/profile in aports
export PATH="$PATH:$HOME/.local/bin"
