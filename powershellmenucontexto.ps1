#pragma script_options(language_version=5.0, suppress_warning=false, default_language=en-US)

# Este script garante que a associação de arquivos .ps1 esteja correta
# e adiciona opções de execução ao menu de contexto.
# Ele precisa ser executado apenas uma vez.

#region Verificação de Privilégios de Administrador
# Verificando se o script está sendo executado como administrador
if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Host "[ERRO] Este script precisa ser executado com privilégios de administrador." -ForegroundColor Red
    Write-Host "Por favor, clique com o botão direito no arquivo e selecione 'Executar como administrador'."
    Read-Host "Pressione Enter para sair..." | Out-Null
    exit
}
#endregion Verificação de Privilégios de Administrador

Write-Host "Iniciando a verificação e modificação do Registro..."

try {
    # Define o caminho para a chave do Registro para a extensão .ps1
    $extPath = "Registry::HKEY_CLASSES_ROOT\.ps1"
    
    # 1. Corrige a associação de arquivo para .ps1
    # Define o valor padrão da chave .ps1 para 'Microsoft.PowerShellScript.1'
    Write-Host "Corrigindo a associação do tipo de arquivo .ps1..."
    Set-ItemProperty -Path $extPath -Name "(default)" -Value "Microsoft.PowerShellScript.1" -Force | Out-Null
    
    # Define os caminhos das chaves para as opções de menu de contexto
    $shellPath = "Registry::HKEY_CLASSES_ROOT\Microsoft.PowerShellScript.1\Shell"
    $runAsPath = "$shellPath\RunAs"
    $runPath = "$shellPath\Run"
    
    # 2. Adiciona a opção "Executar com PowerShell como administrador"
    Write-Host "Adicionando a opção 'Executar com PowerShell como administrador'..."
    New-Item -Path $runAsPath -Force | Out-Null
    Set-ItemProperty -Path $runAsPath -Name "(default)" -Value "Executar com PowerShell como administrador" -Force | Out-Null
    New-Item -Path "$runAsPath\Command" -Force | Out-Null
    Set-ItemProperty -Path "$runAsPath\Command" -Name "(default)" -Value "powershell.exe -ExecutionPolicy Bypass -NoExit -Command `"Set-Location -Path '%V'; & '%1'`"" -Force | Out-Null

    # 3. Adiciona a opção "Executar com PowerShell"
    Write-Host "Adicionando a opção 'Executar com PowerShell'..."
    New-Item -Path $runPath -Force | Out-Null
    Set-ItemProperty -Path $runPath -Name "(default)" -Value "Executar com PowerShell" -Force | Out-Null
    New-Item -Path "$runPath\Command" -Force | Out-Null
    Set-ItemProperty -Path "$runPath\Command" -Name "(default)" -Value "powershell.exe -NoExit -Command `"Set-Location -Path '%V'; & '%1'`"" -Force | Out-Null
    
    Write-Host ""
    Write-Host "[SUCESSO] As opções de menu de contexto foram adicionadas!" -ForegroundColor Green
    Write-Host "Pode ser necessário reiniciar o Explorador de Arquivos ou o computador para que as alterações apareçam."
}
catch {
    Write-Host ""
    Write-Host "[ERRO CRÍTICO] Falha ao modificar o Registro." -ForegroundColor Red
    Write-Host "Mensagem de erro: $($_.Exception.Message)"
}

Write-Host ""
Read-Host "Pressione Enter para sair..." | Out-Null
