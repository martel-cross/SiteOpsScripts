
$cbatlUser = "cbatl\jterry.site"
$cbatlFile = "acklog2.txt"
#$credential=New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $cbatlUser,(Get-Content $cbatlFile | ConvertTo-SecureString)
$Credential = get-credential
$headers = @{'Content-Type' = 'application/json; charset=utf-8'; }

$uri = "http://siteopssupport.careerbuilder.com/rest/api/latest/issue/"
$key = "IRQ"
$summary = "TEST TEST TEST IGNORE IGNORE IGNORE"
$description = "Automation test ignore"
$issuetypename = "Request"
 [String] $Username = $Credential.UserName 
       $token = [System.Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes()) 
       $headers.Add('Authorization', "Basic $token") 

#$newticketformat = '{
    # "fields": {
       # "project":
       # { 
          # "key": "TEST"
       # },
       # "summary": "REST ye merry gentlemen.",
       # "description": "Creating of an issue using project keys and issue type names using the REST API",
       # "issuetype": {
          # "name": "Bug"
       # }
   # }
# }'
#$newticket =$newticketformat |convertfrom-json
$newticket =@{}
$newticket.fields =@{}
$newticket.fields.project = @{}
$newticket.fields.issuetype =@{}
$newticket.fields.issuetype.name ="Task"
$newticket.fields.project.key = $key
$newticket.fields.summary = $summary
$newticket.fields.description = $description

$request = ($newticket | convertto-json)
#$request=($newticket | Convertto-Json -Compress -Depth 3).split() -join""
#$request
$cleanBody = [System.Text.Encoding]::UTF8.GetBytes($request)
Invoke-WebRequest -Uri $URI -Headers $headers -Method Post -Body $cleanBody -contenttype json
#$new =Invoke-restmethod -uri http://siteopssupport.careerbuilder.com/rest/api/latest/issue/  -headers $headers -contenttype json -method post -body $request  -usedefaultcredentials
 # $url = 'https://siteopssupport.careerbuilder.com/rest/api/latest/issue/'
 # $wc = New-Object System.Net.WebClient
 # $wc.Credentials = New-Object System.Net.NetworkCredential($cbatlCreds)
 # $wc.DownloadString($url)
#curl -credential (get-credential) -method POST -body $request -contenttype json -uri http://siteopssupport.careerbuilder.com/rest/api/latest/issue/

# $searchissue.issues | foreach{
 # if ($_.fields.status.statuscategory.name -eq "To Do"){$searchissue.issues}
#if ($_.fields.status.statuscategory.name -eq "To Do") {write-host -foregroundcolor "Red" "TO DO"}
# }
  # $issue = Invoke-restmethod -uri http://siteopssupport.careerbuilder.com/rest/api/latest/search?jql=project=irq
 # if ($issue.issues.fields.description -like "*test*"){$issue.issues.key}
#http://siteopssupport.careerbuilder.com/secure/CreateIssueDetails!init.jspa?pid=10420&issuetype=3&summary=say+hello+world&fixVersions=10331&fixVersions=13187"