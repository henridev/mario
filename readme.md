- region folding in vscode to make a region `ctrl+m and ctrl+r` while wrapped region is selected
- with #regin extension 
{
    "maptz.regionfolder": {
        "[lua]": { //Language selector
            "foldEnd": "--endregion", //Text inserted at the end of the fold
            "foldEndRegex": "[\\s]*--endregion", //Regex used to find fold end text.
            "foldStart": "--region [NAME]", //Text inserted at the start of the fold.
            //Use the `[NAME]` placeholder to indicate
            //where the cursor should be placed after
            //insertion
            "foldStartRegex": "[\\s]*--region[\\s]*(.*)" ////Regex used to find fold start text.
        }
    }
}
