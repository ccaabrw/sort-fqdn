# sort-fqdn
Sort a list of FQDN's into TLD order

Names are compared label by label from right to left (TLD, then domain, then
each sub-domain), case-insensitively and ignoring any trailing dot. Each name
is output exactly as given; blank lines are ignored.

## Bash

```sh
./sort-fqdn.sh hosts.txt          # from one or more files
cat hosts.txt | ./sort-fqdn.sh    # from standard input
```

## PowerShell

```powershell
./sort-fqdn.ps1 -Path hosts.txt
Get-Content hosts.txt | ./sort-fqdn.ps1
./sort-fqdn.ps1 www.example.com mail.example.org example.com
```

## Example

Input:

```
www.example.com
mail.example.org
example.com
ftp.example.co.uk
z.net
```

Output:

```
example.com
www.example.com
z.net
mail.example.org
ftp.example.co.uk
```
