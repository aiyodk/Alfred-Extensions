#!/bin/bash

function VMicon {
    # Choose Icon based on OS type
    case "$1" in
        Windows*)
            echo windows
        ;;
        "Mac OS X"*)
            echo osx
        ;;
        OpenBSD*)
            echo openbsd
        ;;
        FreeBSD*)
            echo freebsd
        ;;
        NetBSD*)
            echo netbsd
        ;;
        Ubuntu*)
            echo ubuntu
        ;;
        Fedora*)
            echo fedora
        ;;
        "Red Hat"*)
            echo redhat
        ;;
        openSUSE*)
            echo suse
        ;;
        Debian*)
            echo debian
        ;;
        Gentoo*|Mandriva*|Turbulinux*|Xandos*|Oracle*|Linux*)
            echo linux
        ;;
        *)
            echo icon
        ;;
    esac
}

# Case insensitive compare
shopt -s nocasematch


# cache list of vms
let "TIME=$(date +%s)-10" # keep VMs cache in 10 seconds
if [ -z "$1" ] || [ $(stat -f "%m" ~/Library/Caches/com.runningwithcrayons.Alfred-2/Workflow\ Data/dk.aiyo.VirtualBoxControl/vms) -ge $TIME ]
   then
   # cache the VMs
    if [ ! -d ~/Library/Caches/com.runningwithcrayons.Alfred-2/Workflow\ Data/dk.aiyo.VirtualBoxControl/ ]
        then
        mkdir ~/Library/Caches/com.runningwithcrayons.Alfred-2/Workflow\ Data/dk.aiyo.VirtualBoxControl
    fi
    VBoxManage list vms -l | sed -n -e '/^Name/N' -e '/\nGroups/P' -e '/\nGuest OS/p' -e '/^Guest OS/P' -e '/^UUID/P' -e '/^State/P' > ~/Library/Caches/com.runningwithcrayons.Alfred-2/Workflow\ Data/dk.aiyo.VirtualBoxControl/vms
fi

#------------

# check if a VM is selected
if [[ $(echo "$1" | grep -c " >" ) -gt 0 ]]
    then
    # Try to extract VM name from query
    NAME=${1%%" >"*}
    # try to find VM in cache (only match the full name)
    VMINFO=$(grep -A 3 "$NAME$" ~/Library/Caches/com.runningwithcrayons.Alfred-2/Workflow\ Data/dk.aiyo.VirtualBoxControl/vms)
    if [[ ! -z "$VMINFO" ]]
        then
        # get UUID for reference
        UUID=$(echo $VMINFO | egrep -o '[0-9abcdef]{8}-[0-9abcdef]{4}-[0-9abcdef]{4}-[0-9abcdef]{4}-[0-9abcdef]{12}')
        ICON=$(VMicon "$(echo ${VMINFO#*'Guest OS: '})")
        # make sure name is xml valid
        NAME=$(printf "$NAME" | sed -e 's/&/&amp;/g')
    fi
fi

# prepare query for fuzzy match
QUERY=$(echo "$1" | sed -e 's/^ *//' -e 's/ *$//' -e 's/ /*\\ /g')

echo '<?xml version="1.0"?>'
echo '<items>'

# if $UUID is set then a VM is selected - check if status is 'running' if so then show options for VM
if [ ! -z "$UUID" ] && [ $(echo $VMINFO | egrep -c " running ") -gt 0 ]
    then
    # the VM is Running

    # remove vm name from query
    QUERY="${QUERY#*' >'}"

    # list options available for the VM with fuzzymatch search
    if [[ " power off" == $QUERY* ]]
        then
        # Power Off
        echo "<item uid=\"virtualbox power off\" arg=\"controlvm $UUID poweroff\" autocomplete=\"$NAME > Power Off\">"
        echo "<title>Power Off</title>"
        echo "<icon>$ICON.png</icon>"
        echo "</item>"
    fi
    if [[ " acpi shutdown" == $QUERY* ]]
        then
        # ACPI Shutdown
        echo "<item uid=\"virtualbox acpi\" arg=\"controlvm $UUID acpipowerbutton\" autocomplete=\"$NAME > ACPI Shutdown\">"
        echo "<title>ACPI Shutdown</title>"
        echo "<icon>$ICON.png</icon>"
        echo "</item>"
    fi
    if [[ " pause" == $QUERY* ]]
        then
        # Pause
        echo "<item uid=\"virtualbox pause\" arg=\"controlvm $UUID pause\" autocomplete=\"$NAME > Pause\">"
        echo "<title>Pause</title>"
        echo "<icon>$ICON.png</icon>"
        echo "</item>"
    fi
    if [[ " save state" == $QUERY* ]]
        then
        # Save Machine State
        echo "<item uid=\"virtualbox savestate\" arg=\"controlvm $UUID savestate\" autocomplete=\"$NAME > Save State\">"
        echo "<title>Save State</title>"
        echo "<icon>$ICON.png</icon>"
        echo "</item>"
    fi
    if [[ " reset" == $QUERY* ]]
        then
        # Reset
        echo "<item uid=\"virtualbox reset\" arg=\"controlvm $UUID reset\" autocomplete=\"$NAME > Reset\">"
        echo "<title>Reset</title>"
        echo "<icon>$ICON.png</icon>"
        echo "</item>"
    fi
    if [[ " take a screenshot" == $QUERY* ]]
        then
        # Screen Shot
        FILENAME=$(echo "~/Desktop/$NAME - Screen Shot $(date +"%Y-%m-%d at %H.%M.%S").png" | sed -e 's/ /\\ /g' -e 's/&/\\&/g')
        echo "<item uid=\"virtualbox screenshot\" arg=\"controlvm $UUID screenshotpng $FILENAME\" autocomplete=\"$NAME > Reset\">"
        echo "<title>Take a Screenshot</title>"
        echo "<icon>$ICON.png</icon>"
        echo "</item>"
    fi
    # make a Back item. this links back to VM options or list of VMs
    if [[ "> " == $QUERY* ]]
        then
        BACK=""
    else
        BACK="$NAME > "
    fi
    echo "<item uid=\"virtualbox back\" autocomplete=\"$BACK\" valid=\"no\">"
    echo "<title>Back...</title>"
    echo "<icon>icon.png</icon>"
    echo "</item>"

elif [ ! -z "$UUID" ] && [ $(echo $VMINFO | egrep -c " saved ") -gt 0 ]
    then
    # the VM is in Saved State mode

    # remove vm name from query
    QUERY="${QUERY#*' >'}"

    # list options available for the VM with fuzzymatch search
    if [[ " Start VM" == $QUERY* ]]
        then
        # ACPI Shutdown
        echo "<item uid=\"virtualbox start\" arg=\"startvm $UUID\" autocomplete=\"$NAME > Start VM\">"
        echo "<title>Start VM</title>"
        echo "<icon>$ICON.png</icon>"
        echo "</item>"
    fi
    if [[ " Discard Saved State" == $QUERY* ]]
        then
        # Pause
        echo "<item uid=\"virtualbox discard\" arg=\"discardstate $UUID\" autocomplete=\"$NAME > Discard Saved State\">"
        echo "<title>Discard Saved State</title>"
        echo "<icon>$ICON.png</icon>"
        echo "</item>"
    fi
    # make a Back item. this links back to VM options or list of VMs
    if [[ "> " == $QUERY* ]]
        then
        BACK=""
    else
        BACK="$NAME > "
    fi
    echo "<item uid=\"virtualbox back\" autocomplete=\"$BACK\" valid=\"no\">"
    echo "<title>Back...</title>"
    echo "<icon>icon.png</icon>"
    echo "</item>"

else
    # no VM was selected, get VMs and list them    

    while read LINE
    do 

    case "$LINE" in
        "Name:"*)
            NAME=$(echo $LINE | sed -e 's/^Name: *//' -e 's/&/&amp;/g' -e 's/</\&lt;/g' -e 's/>/\&gt;/g')
            ;;
        "UUID:"*)
            UUID=$(echo $LINE | sed -e 's/UUID: *//')
            ;;
        "Guest OS:"*)
            ICON=$(VMicon "$(echo $LINE | sed -e 's/Guest OS: *//')")
            ;;
        "State:"*)
            if [ ! -z "$NAME" ] && [ ! -z "$UUID" ] && [ ! -z "$ICON" ]
                then
                 # fuzzy match query
                if [[ " $NAME" == *\ $QUERY* ]]
                    then
                    if [[ $(echo $LINE | grep -c "powered off") -gt 0 ]]
                        then
                        # VM is not running make a start link
                        echo "<item uid=\"$UUID\" arg=\"startvm $UUID\" autocomplete=\"$NAME\">"
                        echo "<title>$NAME</title>"
                        echo "<subtitle>Start Virtual Machine</subtitle>"

                    elif [[ $(echo $LINE | grep -c "aborted") -gt 0 ]]
                        then
                        # VM is aborted make a start link
                        echo "<item uid=\"$UUID\" arg=\"startvm $UUID\" autocomplete=\"$NAME\">"
                        echo "<title>$NAME (Aborted)</title>"
                        echo "<subtitle>Start Virtual Machine</subtitle>"

                    elif [[ $(echo $LINE | grep -c "paused") -gt 0 ]]
                        then
                        # VM is paused, make a resume link
                        echo "<item uid=\"$UUID\" arg=\"controlvm $UUID resume\" autocomplete=\"$NAME\">"
                        echo "<title>$NAME (Paused)</title>"
                        echo "<subtitle>Resume Virtual Machine</subtitle>"

                    elif [[ $(echo $LINE | grep -c "saved") -gt 0 ]]
                        then
                        # VM is in a saved state, link to list of options
                        echo "<item uid=\"$UUID\" autocomplete=\"$NAME > \" valid=\"no\">"
                        echo "<title>$NAME (Saved State)</title>"
                        echo "<subtitle>Start or Discard Saved State of Virtual Machine</subtitle>"

                    else
                        # VM is running, link to list of options
                        echo "<item uid=\"$UUID\" autocomplete=\"$NAME > \" valid=\"no\">"
                        echo "<title>$NAME (Running)</title>"
                        echo "<subtitle>Pause, Save State, Power Off or Reset Virtual Machine</subtitle>"
                    fi

                    echo "<icon>$ICON.png</icon>"
                    echo "</item>"
                fi
            fi
            ;;
    esac

    done < ~/Library/Caches/com.runningwithcrayons.Alfred-2/Workflow\ Data/dk.aiyo.VirtualBoxControl/vms
fi

echo '</items>'
shopt -u nocasematch
