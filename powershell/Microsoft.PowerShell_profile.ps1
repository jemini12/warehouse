Import-Module posh-git
Import-Module oh-my-posh
Set-Theme Paradox 

#requires -Version 2 -Modules posh-git

function Write-Theme {
    param(
        [bool]
        $lastCommandFailed,
        [string]
        $with
    )
    $adminsymbol = $sl.PromptSymbols.ElevatedSymbol
    $venvsymbol = $sl.PromptSymbols.VirtualEnvSymbol
    $clocksymbol = $sl.PromptSymbols.ClockSymbol
    $calandersymbol = $sl.PromptSymbols.CalanderSymbol

    ## Left Part
    $prompt = Write-Prompt -Object " $($sl.PromptSymbols.StartSymbol) " -ForegroundColor $sl.Colors.SessionInfoForegroundColor -BackgroundColor $sl.Colors.SessionInfoBackgroundColor
    $prompt += Write-Prompt -Object "$($sl.PromptSymbols.SegmentForwardSymbol) " -ForegroundColor $sl.Colors.SessionInfoBackgroundColor -BackgroundColor $sl.Colors.DriveBackgroundColor
    $pathSymbol = if ($pwd.Path -eq $HOME) { $sl.PromptSymbols.PathHomeSymbol } else { $sl.PromptSymbols.PathSymbol }
    
    # Writes the drive portion
    $path = $pathSymbol + " " + (Get-FullPath -dir $pwd ) + " "
    $prompt += Write-Prompt -Object $path -ForegroundColor $sl.Colors.DriveForegroundColor -BackgroundColor $sl.Colors.DriveBackgroundColor

    $status = Get-VCSStatus
    if ($status) {
        $themeInfo = Get-VcsInfo -status ($status)
        $prompt += Write-Prompt -Object $sl.PromptSymbols.SegmentSubForwardSymbol -ForegroundColor $sl.Colors.PromptForegroundColor -BackgroundColor $sl.Colors.SessionInfoBackgroundColor
        $prompt += Write-Prompt -Object " $($themeInfo.VcInfo) " -ForegroundColor $themeInfo.BackgroundColor -BackgroundColor $sl.Colors.SessionInfoBackgroundColor
    }
    If ($with) {
        $sWith = " $($with.ToUpper())"
        $prompt += Write-Prompt -Object $sl.PromptSymbols.SegmentSubForwardSymbol -ForegroundColor $sl.Colors.PromptForegroundColor -BackgroundColor $sl.Colors.SessionInfoBackgroundColor
        $prompt += Write-Prompt -Object $sWith -ForegroundColor $sl.Colors.WithForegroundColor -BackgroundColor $sl.Colors.SessionInfoBackgroundColor
    }
    $prompt += Write-Prompt -Object $sl.PromptSymbols.SegmentForwardSymbol -ForegroundColor $sl.Colors.DriveBackgroundColor 
    ###

    ## Right Part
    $rightElements = New-Object 'System.Collections.Generic.List[Tuple[string,ConsoleColor,ConsoleColor]]'
    # $login = $sl.CurrentUser
    # $computer = [System.Environment]::MachineName;

    $rightElements.Add([System.Tuple]::Create($sl.PromptSymbols.SegmentBackwardSymbol, $sl.Colors.SessionInfoBackgroundColor, $sl.Colors.SessionInfoBackgroundColor))
    # $rightElements.Add([System.Tuple]::Create($sl.PromptSymbols.SegmentBackwardSymbol, $sl.Colors.UserForegroundColor, $sl.Colors.SessionInfoBackgroundColor))
    # List of all right elements
    if (Test-VirtualEnv) {
        $rightElements.Add([System.Tuple]::Create(" $(Get-VirtualEnvName) $venvsymbol ", $sl.Colors.VirtualEnvForegroundColor, $sl.Colors.SessionInfoBackgroundColor))
        $rightElements.Add([System.Tuple]::Create($sl.PromptSymbols.SegmentSubBackwardSymbol, $sl.Colors.PromptForegroundColor, $sl.Colors.SessionInfoBackgroundColor))
    }
    if (Test-Administrator) {
        $rightElements.Add([System.Tuple]::Create("  $adminsymbol", $sl.Colors.AdminIconForegroundColor, $sl.Colors.SessionInfoBackgroundColor))
    }
    # $rightElements.Add([System.Tuple]::Create(" $login@$computer ", $sl.Colors.SessionInfoForegroundColor, $sl.Colors.UserForegroundColor))
    # $rightElements.Add([System.Tuple]::Create($sl.PromptSymbols.SegmentBackwardSymbol, $sl.Colors.SessionInfoBackgroundColor, $sl.Colors.UserForegroundColor))
    $rightElements.Add([System.Tuple]::Create(" $(Get-Date -UFormat "%Y/%m/%d") $calandersymbol $(Get-Date -Format HH:mm:ss) $clocksymbol ", $sl.Colors.SessionInfoForegroundColor, $sl.Colors.SessionInfoBackgroundColor))
    $lengthList = [Linq.Enumerable]::Select($rightElements, [Func[Tuple[string, ConsoleColor, ConsoleColor], int]] { $args[0].Item1.Length })
    $total = [Linq.Enumerable]::Sum($lengthList)
    # Transform into total length
    $prompt += Set-CursorForRightBlockWrite -textLength $total
    # The line head needs special care and is always drawn
    $prompt += Write-Prompt -Object $rightElements[0].Item1 -ForegroundColor $rightElements[0].Item2
    for ($i = 1; $i -lt $rightElements.Count; $i++) {
        $prompt += Write-Prompt -Object $rightElements[$i].Item1 -ForegroundColor $rightElements[$i].Item2 -BackgroundColor $rightElements[$i].Item3
    }
    ###

    $prompt += Write-Prompt -Object "`r"
    $prompt += Set-Newline

    # Writes the postfixes to the prompt
    $indicatorColor = If ($lastCommandFailed) { $sl.Colors.CommandFailedIconForegroundColor } Else { $sl.Colors.PromptSymbolColor }
    $prompt += Write-Prompt -Object $sl.PromptSymbols.PromptIndicator -ForegroundColor $indicatorColor
    $prompt += ' '
    $prompt
}

$sl = $global:ThemeSettings #local settings
$sl.PromptSymbols.StartSymbol = [char]::ConvertFromUtf32(0xe62a)
$sl.PromptSymbols.PromptIndicator = [char]::ConvertFromUtf32(0x276F)
$sl.PromptSymbols.SegmentForwardSymbol = [char]::ConvertFromUtf32(0xE0B0)
$sl.PromptSymbols.SegmentSubForwardSymbol = [char]::ConvertFromUtf32(0xE0B1)
$sl.PromptSymbols.SegmentBackwardSymbol = [char]::ConvertFromUtf32(0xE0B2)
$sl.PromptSymbols.SegmentSubBackwardSymbol = [char]::ConvertFromUtf32(0xE0B3)
$sl.PromptSymbols.ClockSymbol = [char]::ConvertFromUtf32(0xf64f)
$sl.PromptSymbols.PathHomeSymbol = [char]::ConvertFromUtf32(0xf015)
$sl.PromptSymbols.PathSymbol = [char]::ConvertFromUtf32(0xf07c)
$sl.PromptSymbols.CalanderSymbol = [char]::ConvertFromUtf32(0xf073)
$sl.Colors.PromptBackgroundColor = [ConsoleColor]::DarkBlue
$sl.Colors.SessionInfoBackgroundColor = [ConsoleColor]::Black
$sl.Colors.VirtualEnvBackgroundColor = [ConsoleColor]::DarkGray
$sl.Colors.PromptSymbolColor = [ConsoleColor]::Gray
$sl.Colors.CommandFailedIconForegroundColor = [ConsoleColor]::DarkRed
$sl.Colors.DriveForegroundColor = [ConsoleColor]::Black
$sl.Colors.PromptForegroundColor = [ConsoleColor]::Gray
$sl.Colors.SessionInfoForegroundColor = [ConsoleColor]::White
$sl.Colors.WithForegroundColor = [ConsoleColor]::Red
$sl.Colors.VirtualEnvForegroundColor = [System.ConsoleColor]::Magenta
$sl.Colors.TimestampForegroundColor = [ConsoleColor]::Green
$sl.Colors.UserForegroundColor = [ConsoleColor]::Yellow
$sl.Colors.GitForegroundColor = [ConsoleColor]::Black
$sl.Colors.DriveBackgroundColor = [ConsoleColor]::DarkBlue

# Host Foreground
$Host.PrivateData.ErrorForegroundColor = 'Red'
$Host.PrivateData.WarningForegroundColor = 'Yellow'
$Host.PrivateData.DebugForegroundColor = 'Green'
$Host.PrivateData.VerboseForegroundColor = 'Blue'
$Host.PrivateData.ProgressForegroundColor = 'Gray'

# Host Background
$Host.PrivateData.ErrorBackgroundColor = 'DarkGray'
$Host.PrivateData.WarningBackgroundColor = 'DarkGray'
$Host.PrivateData.DebugBackgroundColor = 'DarkGray'
$Host.PrivateData.VerboseBackgroundColor = 'DarkGray'
$Host.PrivateData.ProgressBackgroundColor = 'Cyan'

# Check for PSReadline
if (Get-Module -ListAvailable -Name "PSReadline") {
    $options = Get-PSReadlineOption

	if ([System.Version](Get-Module PSReadline).Version -lt [System.Version]"2.0.0") {
		# Foreground
		$options.CommandForegroundColor = 'Yellow'
		$options.ContinuationPromptForegroundColor = 'Green'
		$options.DefaultTokenForegroundColor = 'Green'
		$options.EmphasisForegroundColor = 'Cyan'
		$options.ErrorForegroundColor = 'Red'
		$options.KeywordForegroundColor = 'Green'
		$options.MemberForegroundColor = 'DarkCyan'
		$options.NumberForegroundColor = 'DarkCyan'
		$options.OperatorForegroundColor = 'DarkGreen'
		$options.ParameterForegroundColor = 'DarkGreen'
		$options.StringForegroundColor = 'DarkGreen'
		$options.TypeForegroundColor = 'DarkYellow'
		$options.VariableForegroundColor = 'Green'

		# Background
		$options.CommandBackgroundColor = 'Black'
		$options.ContinuationPromptBackgroundColor = 'Black'
		$options.DefaultTokenBackgroundColor = 'Black'
		$options.EmphasisBackgroundColor = 'Black'
		$options.ErrorBackgroundColor = 'Black'
		$options.KeywordBackgroundColor = 'Black'
		$options.MemberBackgroundColor = 'Black'
		$options.NumberBackgroundColor = 'Black'
		$options.OperatorBackgroundColor = 'Black'
		$options.ParameterBackgroundColor = 'Black'
		$options.StringBackgroundColor = 'Black'
		$options.TypeBackgroundColor = 'Black'
		$options.VariableBackgroundColor = 'Black'
	} else {
	    # New version of PSReadline renames Foreground colors and eliminates Background
		$options.CommandColor = 'Yellow'
		$options.ContinuationPromptColor = 'White'
		$options.DefaultTokenColor = 'White'
		$options.EmphasisColor = 'Cyan'
		$options.ErrorColor = 'Red'
		$options.KeywordColor = 'White'
		$options.MemberColor = 'DarkCyan'
		$options.NumberColor = 'DarkCyan'
		$options.OperatorColor = 'DarkGreen'
		$options.ParameterColor = 'DarkGreen'
		$options.StringColor = 'DarkGreen'
		$options.TypeColor = 'DarkYellow'
		$options.VariableColor = 'Green'
	}
}