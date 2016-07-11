
$targetdrive = "\\mailsm101\c$"
$Files = get-childitem $targetdrive -recurse
$files | sort length -descending | select fullname,Length -first 20