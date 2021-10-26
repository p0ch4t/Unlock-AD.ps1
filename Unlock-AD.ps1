$tries = 0
$user = Read-Host "[+] Usuario: "
while ($tries -lt 50) {
    try{
		$HOSTANAME_SERVIDOR = *** AQUI DEBE INTRODUCIR EL HOSTNAME DE SU SERVIDOR ***
        $PSSess = New-PSSession -ComputerName $HOSTNAME_SERVIDOR 2>$null
        Write-Output ""
        Invoke-Command -Session $PSSess {Get-ADUser $using:user -Properties * | Select LockedOut, PasswordExpired, PasswordLastSet | Format-Table}
        $blocked_status = Invoke-Command -Session $PSSess {Get-ADUser $using:user -Properties * | ForEach-Object {$_.LockedOut} }
        $r = ""
        if ("True" -eq $blocked_status) {
            while ($r -ne "SI" -and $r -ne "NO") {
                $r = Read-Host "[+] Desea desbloquear al usuario? (SI/NO): "
                if ($r -ne "SI" -and $r -ne "NO") {
                    Write-Host "[-] Por favor, introduzca 'SI' o 'NO'."
                    Write-Output ''
                }
                if ($r -eq "SI") {
                    Invoke-Command -Session $PSSess {Unlock-ADAccount -Identity $using:user}
                    Write-Output ''
                    Write-Host "[+] $user ha sido desbloqueado satisfactoriamente."
                }
            }
        }
        $tries = 50
        Write-Output ''
        Read-Host " Presione Enter para cerrar..."
    }
    catch{
        Write-Host "[-] No se pudo conectar al servidor. Intentando nuevamente..."
    }
}