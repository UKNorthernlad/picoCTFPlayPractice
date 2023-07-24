# Manually download the "enc" file from the picoCTF site and put it into the same folder as this PowerShell script. This will be an UTF8 file.
# The URL will be something like "https://mercury.picoctf.net/static/XXXXXXXXXXXX/enc"

$fileBytes = Get-Content -Encoding UTF8 .\enc

# We can read the decimal value of each Unicode character in the $array string like this:
# [int]$array[0] ==> 28777
# [int]$array[1] ==> 25455
# [int]$array[0] ==> 17236
# ... etc.

# The decimal value of each Unicode character in the "enc" file is as follows (this will be different for each user):

#$array = (28777, 25455, 17236, 18043, 12598, 24418, 26996, 29535, 26990, 29556, 13108, 25695, 28518, 24376, 24421, 12596, 12641, 12390, 14205);

# Below is the code provided in the challenge, I guessed that this was used to encrypt the original flag file into the "enc" file.

#    ''.join([chr((ord(flag[i]) << 8) + ord(flag[i + 1])) for i in range(0, len(flag), 2)])

# It works by taking pairs of bytes from the origianl flag file and fusing them together into a new Unicode character.
# The ascii value of the first byte is multiplied by 256 ( shift left 8) then the ascii value of the second byte is added to get a final number. This is then treated as a 2-bytes unicode character.
# This is repeated for each pair of bytes in the source flag file.

# To "unencrypt" this and recover the original flag string, we need to take each unicode character and break it into it's 2 original byte values.
# All we know for sure, is that each byte value lies between 0 and 127 (or 32 and 126 - the printable characters).
# We will have to guess at one of the characters and then calcuate from that guess that the other is.
# As long as both values fall in the 0-127 range, it's a possible solution.
# Both numbers need to be whole numbers, not fractions!


# E.g. The first item in the enc file is: 28777, let's make a few guesses as to what the next ascii character might be by just carrying out the reverse mathmatical operations:
 
# (28777 - 1) / 256 = 112.40625  ==> Not a match as the result is not a whole number
# (28777 - 100) / 256 = 112.01953125  ==> Not a match
# (28777 - 105) / 256 = 112  ==> A possible match, ie, first character = 112 (p) and second is 105 (i)

# Given the flag is in the form: picoCTF{XXXXXX} then it looks like we've got the first 2 characters correct.

# Try the same again for the next pair (let's assume it's going to be "co" to test our theory). The letter "o" is ascii is 111.

# (25455 - 111) / 256 = 99  ==> Match. Char 99 is "c" - so it looks like our theory is correct.

# Here is a script which will do the caclulation across all the items in the array.

$flag = ""

for($arrayCounter = 0; $arrayCounter -lt $fileBytes.length; $arrayCounter ++){

    for($i= 0; $i -le 126; $i++){ # $i is the guess for the second character of each byte pair. This will always be a whole number.

         $result = (($array[$arrayCounter] - $i)/256) # $result is what we calculate the byte to be.

         if($result -is [int]){ # The -is [int] will check for a whole number and return True is it is.

               $flag = $flag + [char]$result + [char]$i # Print out the first and second byte.
         
         }

    }
}

Write-Output $flag
