# hopper
A wrapper around rsync that makes syncing w/ n>1 hops easier

# Basic Usage:
```bash
./hopper.sh source user@hop1 user@dest:~/destination_location
```
Without hopper, this would be equivalent to:
```
rsync -azv -e ssh -o 'ProxyCommand ssh -A user@hop1 nc %h %p'  source user@dest:~/destination_location
```
