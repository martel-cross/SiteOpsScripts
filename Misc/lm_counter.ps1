$a = (get-counter -computername qtmbkp1 -counter '\\qtmbkp1\Network Adapter(Production)\bytes total/sec').countersamples.cookedvalue
$b = (get-counter -computername qtmbkp1 -counter '\\qtmbkp1\Network Adapter(Production)\packets/sec').countersamples.cookedvalue
$c = (get-counter -computername qtmbkp1 -counter '\\qtmbkp1\Network Adapter(Production)\packets received/sec').countersamples.cookedvalue
$d = (get-counter -computername qtmbkp1 -counter '\\qtmbkp1\Network Adapter(Production)\packets sent/sec').countersamples.cookedvalue
$e = (get-counter -computername qtmbkp1 -counter '\\qtmbkp1\Network Adapter(Production)\bytes received/sec').countersamples.cookedvalue
$f = (get-counter -computername qtmbkp1 -counter '\\qtmbkp1\Network Adapter(Production)\bytes sent/sec').countersamples.cookedvalue
write-host "TotalBytesPerSec="$a
write-host "PacketsPerSec="$b
write-host "PacketsRecvsec="$c
write-host "Packetssentsec="$d
write-host "Bytesrecvsec"=$e
write-host "Bytessentsec"=$f
