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

echo $VALID_HOSTS
