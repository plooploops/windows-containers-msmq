# FOR MSMQ Scenarios ONLY #

#MSMQSend gMSA - Receiver on Worker 2
New-ADServiceAccount -Name MSMQSend -DNSHostName MSMQSend.win.local -ServicePrincipalNames host/MSMQSend -PrincipalsAllowedToRetrieveManagedPassword "Domain Controllers", "domain admins", "CN=containerhosts,CN=users,DC=win,DC=local" -KerberosEncryptionType RC4, AES128, AES256
Set-ADServiceAccount -Identity MSMQSend -replace @{ServicePrincipalName='host/MSMQSend','MQQB/MSMQSend','RPC/MSMQSend','TCP/MSMQSend','UDP/MSMQSend'}
Set-ADServiceAccount -Identity MSMQSend -PrincipalsAllowedToRetrieveManagedPassword 'domain admins','domain controllers','containerhosts'
Set-ADServiceAccount -identity MSMQSend -replace @{'msDS-AllowedToDelegateTo'='host/worker2.win.local','LDAP/adVM.win.local','HTTP/worker1.win.local','HTTP/worker2.win.local','HTTP/vsvm.win.local', 'RPC/worker1.win.local', 'RPC/worker2.win.local'}
Set-ADServiceAccount -identity MSMQSend -replace @{userAccountControl=16781312}
SetSPN -l win\MSMQSend$

#MSMQReceiver gMSA - Receiver on Worker 1
New-ADServiceAccount -Name MSMQReceiver -DNSHostName MSMQReceiver.win.local -ServicePrincipalNames http/MSMQReceiver -PrincipalsAllowedToRetrieveManagedPassword "Domain Controllers", "domain admins", "CN=containerhosts,CN=users,DC=win,DC=local" -KerberosEncryptionType RC4, AES128, AES256
Set-ADServiceAccount -Identity MSMQReceiver -replace @{ServicePrincipalName='host/MSMQReceiver','MQQB/MSMQReceiver','RPC/MSMQReceiver','TCP/MSMQReceiver','UDP/MSMQReceiver'}
Set-ADServiceAccount -Identity MSMQReceiver -PrincipalsAllowedToRetrieveManagedPassword 'domain admins','domain controllers','containerhosts'
Set-ADServiceAccount -identity MSMQReceiver -replace @{'msDS-AllowedToDelegateTo'='host/worker1.win.local','LDAP/adVM.win.local','HTTP/worker1.win.local','HTTP/worker2.win.local','HTTP/vsvm.win.local', 'RPC/worker1.win.local', 'RPC/worker2.win.local'}
Set-ADServiceAccount -identity MSMQReceiver -replace @{userAccountControl=16781312}
SetSPN -l win\MSMQReceiver$


# FOR IIS Scenarios ONLY #
#frontend GMSA
New-ADServiceAccount -Name FRONTEND -DNSHostName frontend.win.local -ServicePrincipalNames http/frontend -PrincipalsAllowedToRetrieveManagedPassword "Domain Controllers", "domain admins", "containerhosts" -KerberosEncryptionType RC4, AES128, AES256

Set-ADServiceAccount -Identity frontend -PrincipalsAllowedToRetrieveManagedPassword 'domain admins','domain controllers','containerhosts'
Set-ADServiceAccount -identity frontend -replace @{'msDS-AllowedToDelegateTo'='LDAP/adVM.win.local','HTTP/backendinsider.win.local','HTTP/wrk1.win.local'}
Set-ADServiceAccount -identity frontend -replace @{userAccountControl=16781312}
#confirm SPN
SetSPN -l win\frontend$

#backend GMSA
New-ADServiceAccount -Name BACKEND -DNSHostName backend.win.local -ServicePrincipalNames http/backend -PrincipalsAllowedToRetrieveManagedPassword "Domain Controllers", "domain admins", "containerhosts" -KerberosEncryptionType RC4, AES128, AES256
$impersonation = Get-ADServiceAccount -Identity frontend

Set-ADServiceAccount -Identity backend -PrincipalsAllowedToDelegateToAccount $impersonation
Set-ADServiceAccount -identity backend -replace @{'msDS-AllowedToDelegateTo'='LDAP/adVM.win.local','HTTP/wrk1.win.local'}
Set-ADServiceAccount -identity backend -replace @{userAccountControl=16781312}
#confirm SPN
SetSPN -l win\backend$

#Other Possible AD Additions
$usergroup = New-ADGroup -GroupCategory Security -DisplayName "Web Users" -Name WebUsers -GroupScope Universal
$usergroup | Add-ADGroupMember -Members (Get-ADServiceAccount -Identity APP1,APP2)

$g | Add-ADGroupMember -Members (Get-ADComputer -Identity worker1)