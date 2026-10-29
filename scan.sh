#!/bin/bash

# Use the cut command with CIDR as delimiter and split address and subnet
ADDRESS="$(echo "$1" | cut -d "/" -f 1)"
SUBNET="$(echo "$1" | cut -d "/" -f 2)"
VALID_HOSTS=$(( 2**(32 - SUBNET) - 2 ))

if [[ VALID_HOSTS -eq 0 || SUBNET -lt 1 ]]; then
	echo "Invalid Subnet" $SUBNET
	exit 1
fi

# Convert the IP address into its 32 bit integer value
# Use an Internal Field Seperator to split the octets
IFS='.' read -r -a OCTETS <<< $ADDRESS

# Determine if the address is valid, then scan the range (default range is network range)
if [[ ${OCTETS[0]} -lt 1 ]]; then
	echo "Invalid Address" $ADDRESS
	exit 1	
fi

for octet in "${OCTETS[@]}"; do
	if [[ octet -gt 255 || octet -lt 0 ]]; then
		echo "Invalid Address" $ADDRESS
		exit 1	
	fi
done

# Convert the IP address into its 32 bit integer form 
IP=$(( (${OCTETS[0]} << 24) | (${OCTETS[1]} << 16) | (${OCTETS[2]} << 8) | ${OCTETS[3]} ))

# Shift 32 binary ones (32 - CIDR number) to the left to yeild the subnet in decimal notation
MASK=$(( (0xFFFFFFFF << (32 - SUBNET)) & 0xFFFFFFFF ))

# Get the network address through & with the address and subned
NETWORK=$(( $IP & $MASK ))

# Integer to Binary Converstion Function for ping command
function bin_to_dd {
	OCT1=$(( ($1 >> 24) & 255 ))
	OCT2=$(( ($1 >> 16) & 255 ))
	OCT3=$(( ($1 >> 8) & 255 ))
	OCT4=$(( $1 & 255 ))
	echo "$OCT1.$OCT2.$OCT3.$OCT4"
}

# Checking to see if they want to scan the whole host network
if [ -z $2 ]; then
	read -p "Host range not given, are you sure you want to scan the whole network? [y/N]:" response
	if [[ $response == "n" ]]; then
		echo "Usage: scan {address}/{subnet} {number_of_addresses}"
		exit 1
	fi
	# If they intended to, scan the whole network
	for (( address=$NETWORK+1;address<=$NETWORK+$VALID_HOSTS;address++ )); do
		ping -c 1 -W 1 "$(bin_to_dd $address)" > /dev/null && echo "$(bin_to_dd $address) found, Success!" 
	done
	exit 0
fi

# Scan network from address to second argument
# Check to see if the second argument is in range
if [[ $IP+$2 -gt $NETWORK+$VALID_HOSTS ]]; then
	echo "Addresses out of range of subnet"
	exit 1
fi

# Then scan the range asked
for (( address=$IP;address<=$IP+$2;address++ )); do
	ping -c 1 -W 1 "$(bin_to_dd $address)" > /dev/null && echo "$(bin_to_dd $address) found, Success!" 
done

