<#
Script to publish application using GUI mode. 

Script written by Harinderpal Singh on 17 December 2014.

In case of any queries please send me an email on harinder[at]codezyn.com

#>

Add-pssnapin Citrix.*

$labels = @("BrowserName","DisplayName","Description","WorkerGroupNames","Accounts","CommandLineExecutable","WorkingDirectory","FolderPath","ClientFolder","IconPath","AudioRequired","ColorDepth","InstanceLimit","WindowType")
$i=20
$j=20
$label = @(0..13)
$Textbox = @(0..13)

Add-Type -AssemblyName System.Windows.Forms
$Form = New-Object system.Windows.Forms.Form # form libraries
$Form.Text = "Application publish app" # form title
$Font = New-Object System.Drawing.Font("Times New Roman",12,[System.Drawing.FontStyle]::Italic) # creating fonts 
# Font styles are: Regular, Bold, Italic, Underline, Strikeout
$Form.Font = $Font # applying the fonts formatting to form

For($l=0;$l -le 13;$l++){
    $label[$l] = New-Object System.Windows.Forms.Label # creating variable label libraries
    $label[$l].Location = New-Object System.Drawing.Size(10,$i) # Input text box config
    $label[$l].Text = $labels[$l] # Adding text to label
    $label[$l].AutoSize = $True

    $label[$l].BackColor = "Transparent" 

    $Form.Width = 800 # whole form width
    $Form.Height = 800 # whole form hieght

    $Form.AutoScroll = $True
    # $Form.AutoSizeMode = "GrowAndShrink" # or growonly # Used to control the autosize the form 

    $Form.MinimizeBox = $False # to disable or enable minimize button
    $Form.MaximizeBox = $False # to disable or enable maximize button
    $Form.WindowState = "Normal" # windows startup state minimize or maximize
    # Maximized, Minimized, Normal
    $Form.SizeGripStyle = "hide" # to hide or show expansion symbol on bottom left corner of the form
    # Auto, Hide, Show
    $Form.ShowInTaskbar = $true # It help to show the opened form in task bar or hidden
    $Form.Opacity = 1.0 # setting up the transferency to the form
    # 1.0 is fully opaque; 0.0 is invisible
    $Form.StartPosition = "CenterScreen" # start position of the form


    $Icon = [system.drawing.icon]::ExtractAssociatedIcon($PSHOME + "\powershell.exe") # set the icon for the form with existing *exe file icons
    $Form.Icon = $Icon # link icon with form

    $TextBox[$l] = New-Object System.Windows.Forms.TextBox # Creating input text box
    $TextBox[$l].Location = New-Object System.Drawing.Size(200,$i) # Input text box config
    $TextBox[$l].Size = New-Object System.Drawing.Size(260,20) # Input text box config

    $Form.KeyPreview = $True  # link the keyboard keys with form
    #$Form.Add_KeyDown({if ($_.KeyCode -eq "Enter")  {$x=$TextBox[$l].Text;$Form.Close()}})  # LInk enter key with form
    $Form.Add_KeyDown({if ($_.KeyCode -eq "Escape") {$Form.Close()}})  # LInk escape key with form

    $i=$i+40

}

$OKButton = New-Object System.Windows.Forms.Button # Adding button libraries
$OKButton.Location = New-Object System.Drawing.Size(75,600) # Adding button configuration
$OKButton.Size = New-Object System.Drawing.Size(120,23) # Adding button configuration
$OKButton.Text = "OK"
$OKButton.Add_Click({Validate}) # Adding button click action
$Form.Controls.Add($OKButton) # linking with form

$CancelButton = New-Object System.Windows.Forms.Button
$CancelButton.Location = New-Object System.Drawing.Size(250,600)
$CancelButton.Size = New-Object System.Drawing.Size(120,23)
$CancelButton.Text = "Cancel"
$CancelButton.Add_Click({$Form.Close()})
$Form.Controls.Add($CancelButton)

        
Function Validate
{
	For($l=0;$l -le 13;$l++){
	    if (!$TextBox[$l].Text)
	    {
            if($l -eq 9) { continue; }
		    [System.Windows.Forms.MessageBox]::Show("Please enter value for " + $labels[$l] , "Oops..") 
            break;
	    }
	}
    
    App_publish

}

Function App_publish
    {
    if (!$labels[9].text)
	    {
	    try{
           ##$EncodedIconData = Get-CtxIcon $app.CommandLineExecutable -index 0
	        if ($ver -eq "4") 
			    {
			    $EncodedIconData = Get-XAIconStream $labels[9].text -index 0
			    $EncodedIconData=$EncodedIconData.EncodedIconData
			    }
		    else 
			    {
                if ($app.IconPath.contains('.exe')){$EncodedIconData = Get-CtxIcon $labels[9].text -index 0}
			    else {$EncodedIconData = Get-CtxIcon $labels[9].text}
			    }
		     $EncodedIconData = '"' + $EncodedIconData + '"'
 
            } catch [Exception] {
            Write-Host "Error: Obtaining the icon failed: " $_.Exception.Message
            }
	    }
 
 
    #checking browsername length, found out it has a limit
 
    if($Textbox[0].text -gt 36)
        {
        Write-Host "Error: BrowserName for " $app.BrowserName " length is to long, must be less than 36 characters, please correct" 											
        }
    if ($Textbox[0].text.contains(“.”) -or $Textbox[7].text.contains(“.”) -or $Textbox[8].text.contains(“.”) -or $Textbox[1].text.contains(“.”) -or $Textbox[2].text.contains(“.”)) #Checking . in strings
	    {
        [System.Windows.Forms.MessageBox]::Show("Unacceptable character '.' found kindly revalidate the inputs" , "Oops..") 									
	    break
	    }
    else
        {
 		#$Textbox[0].text = '"' + $Textbox[0].text + '"'   #Adding quotes to Browsername
		#$Textbox[5].text = "'" + $Textbox[5].text + "'"   #Adding quotes to command line executable
		#$Textbox[7].text = '"' + $Textbox[7].text + '"'   #Adding quotes to folder path
		#$Textbox[8].text = '"' + $Textbox[8].text + '"'   #Adding quotes to client folder
		#$Textbox[1].text = '"' + $Textbox[1].text + '"'   #Adding quotes to display name
		#$Textbox[2].text = '"' + $Textbox[2].text + '"'   #adding quotes to description
		#$Textbox[6].text = '"' + $Textbox[6].text + '"'   #Adding quote to working directory
      
        $success = $FALSE
 		if (!$labels[9])
		    {
		    $newapp2 = " -WorkingDirectory " + $Textbox[6].text + " -CommandLineExecutable " + $Textbox[5].text + " -FolderPath " +  $Textbox[7].text + " -ClientFolder " + $Textbox[8].text + " -WindowType " + $Textbox[13].text + " -ColorDepth " + $Textbox[11].text + " -MultipleInstancesPerUserAllowed " + $Textbox[12].text + " -AddToClientStartMenu " + "0" + " -AnonymousConnectionsAllowed " + "0"  + " -EncryptionLevel " + "Bits128" + " -AudioRequired " + $Textbox[10].text + " -EncodedIconData " + $Textbox[9].text + " -ErrorAction Stop "
		    }
	    else
    		{
	    	$newapp2 = " -WorkingDirectory " + $Textbox[6].text + " -CommandLineExecutable " + $Textbox[5].text + " -FolderPath " +  $Textbox[7].text + " -ClientFolder " + $Textbox[8].text + " -WindowType " + $Textbox[13].text + " -ColorDepth " + $Textbox[11].text + " -MultipleInstancesPerUserAllowed " + $Textbox[12].text + " -AddToClientStartMenu " + "0" + " -AnonymousConnectionsAllowed " + "0"  + " -EncryptionLevel " + "Bits128" + " -AudioRequired " + $Textbox[10].text + " -ErrorAction Stop "
		}
		$NewApp = "New-XAApplication -ApplicationType ServerInstalled " + " -ServerNames " + $Textbox[3].text + " -BrowserName " + $Textbox[0].text + " -DisplayName " + $Textbox[1].text + " -Description " + $Textbox[2].text + " -Enabled " + "1" + " -Accounts " + $Textbox[4].text + $newapp2
    
        #try to publish new app
		
 
        try {
 		##	$NewApp
         	iex $NewApp
 
                        
            $success = $TRUE
 
        } catch {
 
             Write-Host "Error: " $_.Exception.Message -foregroundcolor "Red"
 
        } finally {
 
            if($success)
 
            {
 
                Write-Host $app.BrowserName "added successfully." -foregroundcolor "green"
 
            }
 
        }
 
         
 
         
 
    }
 
}


For($l=0;$l -le 13;$l++){
    $Form.Controls.Add($TextBox[$l]) # linking with label and form
    $Form.Controls.Add($label[$l]) # linking with label and form
}
$Form.ShowDialog() # to call form to show up

