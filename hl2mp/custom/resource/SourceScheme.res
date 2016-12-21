///////////////////////////////////////////////////////////
// Tracker scheme resource file
//
// sections:
//		Colors			- all the colors used by the scheme
//		BaseSettings	- contains settings for app to use to draw controls
//		Fonts			- list of all the fonts used by app
//		Borders			- description of all the borders
//
///////////////////////////////////////////////////////////
Scheme
{
	//////////////////////// COLORS ///////////////////////////
	// color details
	// this is a list of all the colors used by the scheme
	Colors
	{
		// base colors
		"Scheme"				"255 100 0 255"
		"White"						"255 255 255 255"
		"OffWhite"					"216 216 216 255"
		"DullWhite"					"142 142 142 255"
		"Black"						"0 0 0 192"
		"Blank"						"0 0 0 0"
		"Grey"						"33 33 33 255"
		"Green"                     "25 255 25 255"
		"Layout"					"255 100 0 255"
	}

	///////////////////// BASE SETTINGS ////////////////////////
	//
	// default settings for all panels
	// controls use these to determine their settings
	BaseSettings
	{
		// vgui_controls color specifications
		Border.Bright					"0 0 0 255"
		Border.Dark					"0 0 0 255"
		Border.Selection				"28 28 28 255"

		Button.TextColor				"White"
		Button.BgColor					"Blank"
		Button.ArmedTextColor				"Layout"
		Button.ArmedBgColor				"Blank"
		Button.DepressedTextColor			"Layout"
		Button.DepressedBgColor				"25 25 25 255"
		Button.FocusBorderColor				"Layout"
		
		CheckButton.TextColor				"Scheme"
		CheckButton.SelectedTextColor			"White"
		CheckButton.BgColor				"Blank"
		CheckButton.Border1  				"0 0 0 120"
		CheckButton.Border2  				"0 0 0 192"
		CheckButton.Check				"White"

		ComboBoxButton.ArrowColor			"Scheme"
		ComboBoxButton.ArmedArrowColor			"250 100 0 150"
		ComboBoxButton.BgColor				"10 10 10 0"
		ComboBoxButton.DisabledBgColor			"10 10 10 255"

		Frame.TitleTextInsetX				"15"
		Frame.ClientInsetX				"8"
		Frame.ClientInsetY				"6"
		Frame.BgColor					"50 50 50 160"
		Frame.OutOfFocusBgColor				"50 50 50 120"
		Frame.FocusTransitionEffectTime			"0.45"
		Frame.TransitionEffectTime			"0.45"
		Frame.AutoSnapRange				"2.50"
		FrameGrip.Color1				"Layout"
		FrameGrip.Color2				"58 58 58 196"
		FrameTitleButton.FgColor			"Scheme"
		FrameTitleButton.BgColor			"Blank"
		FrameTitleButton.DisabledFgColor		"Layout"
		FrameTitleButton.DisabledBgColor		"Blank"
		FrameSystemButton.FgColor			"Blank"
		FrameSystemButton.BgColor			"Blank"
		FrameSystemButton.Icon			""
		FrameSystemButton.DisabledIcon	""
		FrameTitleBar.Font				"UiBold"
		FrameTitleBar.TextColor				"Scheme"
		FrameTitleBar.BgColor				"Blank"
		FrameTitleBar.DisabledTextColor			"255 255 255 192"
		FrameTitleBar.DisabledBgColor			"Blank"

		GraphPanel.FgColor				"White"
		GraphPanel.BgColor				"0 0 0 192"

		Label.TextDullColor				"Layout"
		Label.TextColor					"OffWhite"
		Label.TextBrightColor				"White"
		Label.SelectedTextColor				"White"
		Label.BgColor					"Blank"
		Label.DisabledFgColor1				"100 100 100 255"
		Label.DisabledFgColor2				"50 50 50 255"

		ListPanel.TextColor				"125 125 125 255"
		ListPanel.TextBgColor				"0 0 0 120"
		ListPanel.BgColor				              "0 0 0 120"
		ListPanel.SelectedTextColor			              "White"
		ListPanel.SelectedBgColor			              "Layout"
		ListPanel.SelectedOutOfFocusBgColor		"25 25 25 255"
		ListPanel.EmptyListInfoTextColor		"125 125 125 255"

		Menu.TextColor					"White"
		Menu.BgColor					"Grey"
		Menu.ArmedTextColor				"White"
		Menu.ArmedBgColor				"Layout"
		Menu.TextInset					"10"

		Panel.FgColor					"25 25 25 255"
		Panel.BgColor					"Blank"

		ProgressBar.FgColor				"Layout"
		ProgressBar.BgColor				"0 0 0 120"

		PropertySheet.TextColor				"OffWhite"
		PropertySheet.SelectedTextColor			"White"
		PropertySheet.TransitionEffectTime		"0.25"

		RadioButton.TextColor				"DullWhite"
		RadioButton.SelectedTextColor			"White"

		RichText.TextColor				"OffWhite"
		RichText.BgColor				"0 0 0 120"
		RichText.SelectedTextColor			"White"
		RichText.SelectedBgColor			"Layout"

		ScrollBar.Wide					"17"

		ScrollBarButton.FgColor				"37 37 37 255"
		ScrollBarButton.BgColor				"25 25 25 255"
		ScrollBarButton.ArmedFgColor			"37 37 37 255"
		ScrollBarButton.ArmedBgColor			"25 25 25 255"
		ScrollBarButton.DepressedFgColor		              "37 37 37 255"
		ScrollBarButton.DepressedBgColor		              "25 25 25 255"

		ScrollBarSlider.FgColor				"25 25 25 255"
		ScrollBarSlider.BgColor				"37 37 37 255"

		SectionedListPanel.HeaderTextColor		              "Layout"
		SectionedListPanel.HeaderBgColor		              "Blank"
		SectionedListPanel.DividerColor			"24 24 24 255"
		SectionedListPanel.TextColor			"100 100 100 255"
		SectionedListPanel.BrightTextColor		              "150 150 150 255"
		SectionedListPanel.BgColor			              "0 0 0 120"
		SectionedListPanel.SelectedTextColor		              "White"
		SectionedListPanel.SelectedBgColor		              "Layout"
		SectionedListPanel.OutOfFocusSelectedTextColor	"White"
		SectionedListPanel.OutOfFocusSelectedBgColor	"25 25 25 255"

		Slider.NobColor					"0 0 0 120"
		Slider.TextColor				"180 180 180 255"
		Slider.TrackColor				"Layout"
		Slider.DisabledTextColor1			"100 100 100 255"
		Slider.DisabledTextColor2			"50 50 50 255"

		TextEntry.TextColor				"White"
		TextEntry.BgColor				              "0 0 0 120"
		TextEntry.CursorColor				"OffWhite"
		TextEntry.DisabledTextColor			"DullWhite"
		TextEntry.DisabledBgColor			"Blank"
		TextEntry.SelectedTextColor			              "White"
		TextEntry.SelectedBgColor			              "Layout"
		TextEntry.OutOfFocusSelectedBgColor		"36 138 194 196"
		TextEntry.FocusEdgeColor			"0 0 0 196"

		ToggleButton.SelectedTextColor			"White"

		Tooltip.TextColor				"White"
		Tooltip.BgColor					"Layout"

		TreeView.BgColor				"White"

		WizardSubPanel.BgColor				"Blank"

		// scheme-specific colors
		MainMenu.TextColor				"White"
		MainMenu.ArmedTextColor				"Layout"
		MainMenu.DepressedTextColor			"192 186 80 255"
		MainMenu.MenuItemHeight				"32"
		MainMenu.Inset					"28"
		MainMenu.Backdrop				"58 58 58 154"

		Console.TextColor				"Scheme"
		Console.DevTextColor				"Green"

		NewGame.TextColor				"White"
		NewGame.FillColor				"58 58 58 255"
		NewGame.SelectionColor				"Layout"
		NewGame.DisabledColor				"128 128 128 196"
	}

	//
	//////////////////////// FONTS /////////////////////////////
	//
	// describes all the fonts
	Fonts
	{
		// fonts are used in order that they are listed
		// fonts listed later in the order will only be used if they fulfill a range not already filled
		// if a font fails to load then the subsequent fonts will replace
		// fonts are used in order that they are listed
		"DebugFixed"
		{
			"1"
			{
				"name"		"Courier New"
				"tall"		"10"
				"weight"	"500"
				"antialias" "1"
			}
		}
		// fonts are used in order that they are listed
		"DebugFixedSmall"
		{
			"1"
			{
				"name"		"Courier New"
				"tall"		"7"
				"weight"	"500"
				"antialias" "1"
			}
		}
		"DefaultFixedOutline"
		{
			"1"
			{
				"name"		"Lucida Console"
				"tall"		"10"
				"weight"	"0"
				"dropshadow""0"
				"antialias""1"
				//"additive"	"1"
			}			
			//"1"
			//{
			//	"name"		"Lucida Console"
			//	"tall"		"10"
			//	"weight"	"0"
			//	"outline"	"1"
			//}
		}
		"Default"
		{
			"1"
			{
				"name"		"Arial"
				"tall"		"16"
				"antialias" "1"
				"weight"	"500"
			}
		}
		"DefaultBold"
		{
			"1"
			{
				"name"		"Arial"
				"tall"		"16"
				"antialias" "1"
				"weight"	"1000"
			}
		}
		"DefaultUnderline"
		{
			"1"
			{
				"name"		"Arial"
				"tall"		"16"
				"antialias" "1"
				"weight"	"500"
				"underline" "1"
			}
		}
		"DefaultSmall"
		{
			"1"
			{
				"name"		"Tahoma"
				"tall"		"12"
				"antialias" "0"
				"weight"	"0"
			}
		}
		"DefaultSmallDropShadow"
		{
			"1"
			{
				"name"		"Arial"
				"tall"		"13"
				"antialias" "1"
				"weight"	"0"
				"dropshadow" "1"
			}
		}
		"DefaultVerySmall"
		{
			"1"
			{
				"name"		"Tahoma"
				"tall"		"12"
				"antialias" "0"
				"weight"	"0"
			}
		}

		"DefaultLarge"
		{
			"1"
			{
				"name"		"Arial"
				"tall"		"18"
				"antialias" "1"
				"weight"	"0"
			}
		}
		"UiBold"
		{
			"1"
			{
				"name"		"Tahoma"
				"name"		"Verdana"
				"tall"		"12"
				"weight"	"1000"
			}
		}
		"MenuLarge"
		{
			"1"
			{
				"name"		"Manteka Regular"
				"tall"		"18"
				"weight"	"400"
				"range"		"0x0000 0x017F"
				"antialias" "1"
				"dropshadow" "0"
			}
		}

		"ConsoleText"
		{
			"1"
			{
				"name"		"ProFontWindows"
				"tall"		"13"
				"weight"	"500"
				"dropshadow""1"
				"antialias""1"
			}
		}

		// this is the symbol font
		"Marlett"
		{
			"1"
			{
				"name"		"Marlett"
				"tall"		"14"
				"weight"	"0"
				"symbol"	"1"
			}
		}

		"Trebuchet24"
		{
			"1"
			{
				"name"		"Trebuchet MS"
				"tall"		"24"
				"weight"	"400"
				"antialias"	"1"
				"additive"	"0"
				"dropshadow""1"
			}
		}


		"Trebuchet20"
		{
			"1"
			{
				"name"		"Trebuchet MS"
				"tall"		"20"
				"weight"	"900"
				"antialias"	"1"
				"dropshadow""1"
			}
		}

		"Trebuchet18"
		{
			"1"
			{
				"name"		"Trebuchet MS"
				"tall"		"18"
				"weight"	"900"
				"antialias"	"1"
				"dropshadow""1"
			}
		}

		// HUD numbers
		// We use multiple fonts to 'pulse' them in the HUD, hence the need for many of near size
		"HUDNumber"
		{
			"1"
			{
				"name"		"Trebuchet MS"
				"tall"		"40"
				"weight"	"900"
				
			}
		}
		"HUDNumber1"
		{
			"1"
			{
				"name"		"Trebuchet MS"
				"tall"		"41"
				"weight"	"900"
			}
		}
		"HUDNumber2"
		{
			"1"
			{
				"name"		"Trebuchet MS"
				"tall"		"42"
				"weight"	"900"
			}
		}
		"HUDNumber3"
		{
			"1"
			{
				"name"		"Trebuchet MS"
				"tall"		"43"
				"weight"	"900"
			}
		}
		"HUDNumber4"
		{
			"1"
			{
				"name"		"Trebuchet MS"
				"tall"		"44"
				"weight"	"900"
			}
		}
		"HUDNumber5"
		{
			"1"
			{
				"name"		"Trebuchet MS"
				"tall"		"45"
				"weight"	"900"
			}
		}
		"DefaultFixed"
		{
			"1"
			{
				"name"		"Lucida Console"
				"tall"		"10"
				"weight"	"0"
			}
//			"1"
//			{
//				"name"		"FixedSys"
//				"tall"		"20"
//				"weight"	"0"
//			}
		}

		"DefaultFixedDropShadow"
		{
			"1"
			{
				"name"		"Lucida Console"
				"tall"		"10"
				"weight"	"0"
				"dropshadow" "1"
			}
//			"1"
//			{
//				"name"		"FixedSys"
//				"tall"		"20"
//				"weight"	"0"
//			}
		}

		"CloseCaption_Normal"
		{
			"1"
			{
				"name"		"Arial"
				"tall"		"16"
				"weight"	"500"
			}
		}
		"CloseCaption_Italic"
		{
			"1"
			{
				"name"		"Arial"
				"tall"		"16"
				"weight"	"500"
				"italic"	"1"
			}
		}
		"CloseCaption_Bold"
		{
			"1"
			{
				"name"		"Arial"
				"tall"		"16"
				"weight"	"900"
			}
		}
		"CloseCaption_BoldItalic"
		{
			"1"
			{
				"name"		"Arial"
				"tall"		"16"
				"weight"	"900"
				"italic"	"1"
			}
		}

		TitleFont
		{
			"1"
			{
				"name"		"HalfLife2"
				"tall"		"72"
				"weight"	"400"
				"antialias"	"1"
				"custom"	"1"
			}
		}

		TitleFont2
		{
			"1"
			{
				"name"		"HalfLife2"
				"tall"		"120"
				"weight"	"400"
				"antialias"	"1"
				"custom"	"1"
			}
		}
	}
	//
	//////////////////// BORDERS //////////////////////////////
	//
	// describes all the border types
	Borders
	{
		BaseBorder		DepressedBorder
		ButtonBorder	RaisedBorder
		ComboBoxBorder	DepressedBorder
		MenuBorder		RaisedBorder
		BrowserBorder	DepressedBorder
		PropertySheetBorder	RaisedBorder
		
		PanelBorder
		{
			// rounded corners for frames
			"backgroundtype" "0"
			"inset" "0 0 1 1"
			Left
			{
				"1"
				{
					"color" "Border.Bright"
					"offset" "0 1"
				}
			}

			Right
			{
				"1"
				{
					"color" "Border.Dark"
					"offset" "0 0"
				}
			}

			Top
			{
				"1"
				{
					"color" "Border.Bright"
					"offset" "0 1"
				}
			}

			Bottom
			{
				"1"
				{
					"color" "Border.Dark"
					"offset" "0 0"
				}
			}			
		}
		EditablePanelBorder
		{
			// rounded corners for frames
			"backgroundtype" "0"
			"inset" "0 0 1 1"
			Left
			{
				"1"
				{
					"color" "Border.Bright"
					"offset" "0 1"
				}
			}

			Right
			{
				"1"
				{
					"color" "Border.Dark"
					"offset" "0 0"
				}
			}

			Top
			{
				"1"
				{
					"color" "Border.Bright"
					"offset" "0 1"
				}
			}

			Bottom
			{
				"1"
				{
					"color" "Border.Dark"
					"offset" "0 0"
				}
			}			
		}
		FrameBorder
		{
			// rounded corners for frames
			"backgroundtype" "0"
			"inset" "0 0 1 1"
			Left
			{
				"1"
				{
					"color" "Border.Bright"
					"offset" "0 1"
				}
			}

			Right
			{
				"1"
				{
					"color" "Border.Dark"
					"offset" "0 0"
				}
			}

			Top
			{
				"1"
				{
					"color" "Border.Bright"
					"offset" "0 1"
				}
			}

			Bottom
			{
				"1"
				{
					"color" "Border.Dark"
					"offset" "0 0"
				}
			}			
		}

		DepressedBorder
		{
			"inset" "0 0 1 1"
			Left
			{
				"1"
				{
					"color" "Border.Dark"
					"offset" "0 1"
				}
			}

			Right
			{
				"1"
				{
					"color" "Border.Bright"
					"offset" "1 0"
				}
			}

			Top
			{
				"1"
				{
					"color" "Border.Dark"
					"offset" "0 0"
				}
			}

			Bottom
			{
				"1"
				{
					"color" "Border.Bright"
					"offset" "0 0"
				}
			}
		}
		RaisedBorder
		{
			"inset" "0 0 1 1"
			Left
			{
				"1"
				{
					"color" "Border.Bright"
					"offset" "0 1"
				}
			}

			Right
			{
				"1"
				{
					"color" "Border.Dark"
					"offset" "0 0"
				}
			}

			Top
			{
				"1"
				{
					"color" "Border.Bright"
					"offset" "0 1"
				}
			}

			Bottom
			{
				"1"
				{
					"color" "Border.Dark"
					"offset" "0 0"
				}
			}
		}
		
		TitleButtonBorder
		{
			"backgroundtype" "0"
		}

		TitleButtonDisabledBorder
		{
			"backgroundtype" "0"
		}

		TitleButtonDepressedBorder
		{
			"backgroundtype" "0"
		}

		ScrollBarButtonBorder
		{
			"inset" "2 2 0 0"
			Left
			{
				"1"
				{
					"color" "Border.Bright"
					"offset" "0 1"
				}
			}

			Right
			{
				"1"
				{
					"color" "Border.Dark"
					"offset" "1 0"
				}
			}

			Top
			{
				"1"
				{
					"color" "Border.Bright"
					"offset" "0 0"
				}
			}

			Bottom
			{
				"1"
				{
					"color" "Border.Dark"
					"offset" "0 0"
				}
			}
		}
		
		ScrollBarButtonDepressedBorder
		{
			"inset" "2 2 0 0"
			Left
			{
				"1"
				{
					"color" "Border.Dark"
					"offset" "0 1"
				}
			}

			Right
			{
				"1"
				{
					"color" "Border.Bright"
					"offset" "1 0"
				}
			}

			Top
			{
				"1"
				{
					"color" "Border.Dark"
					"offset" "0 0"
				}
			}

			Bottom
			{
				"1"
				{
					"color" "Border.Bright"
					"offset" "0 0"
				}
			}
		}

		TabBorder
		{
			"inset" "0 0 1 1"
			Left
			{
				"1"
				{
					"color" "Border.Bright"
					"offset" "0 1"
				}
			}

			Right
			{
				"1"
				{
					"color" "Border.Dark"
					"offset" "1 0"
				}
			}

			Top
			{
				"1"
				{
					"color" "Border.Bright"
					"offset" "0 0"
				}
			}

		}

		TabActiveBorder
		{
			"inset" "0 0 1 0"
			Left
			{
				"1"
				{
					"color" "Border.Bright"
					"offset" "0 0"
				}
			}

			Right
			{
				"1"
				{
					"color" "Border.Dark"
					"offset" "1 0"
				}
			}

			Top
			{
				"1"
				{
					"color" "Border.Bright"
					"offset" "0 0"
				}
			}

		}


		ToolTipBorder
		{
			"inset" "0 0 1 0"
			Left
			{
				"1"
				{
					"color" "Border.Dark"
					"offset" "0 0"
				}
			}

			Right
			{
				"1"
				{
					"color" "Border.Dark"
					"offset" "1 0"
				}
			}

			Top
			{
				"1"
				{
					"color" "Border.Dark"
					"offset" "0 0"
				}
			}

			Bottom
			{
				"1"
				{
					"color" "Border.Dark"
					"offset" "0 0"
				}
			}
		}

		// this is the border used for default buttons (the button that gets pressed when you hit enter)
		ButtonKeyFocusBorder
		{
			"inset" "0 0 1 1"
			Left
			{
				"1"
				{
					"color" "Border.Selection"
					"offset" "0 0"
				}
				"2"
				{
					"color" "Border.Bright"
					"offset" "0 1"
				}
			}
			Top
			{
				"1"
				{
					"color" "Border.Selection"
					"offset" "0 0"
				}
				"2"
				{
					"color" "Border.Bright"
					"offset" "1 0"
				}
			}
			Right
			{
				"1"
				{
					"color" "Border.Selection"
					"offset" "0 0"
				}
				"2"
				{
					"color" "Border.Dark"
					"offset" "1 0"
				}
			}
			Bottom
			{
				"1"
				{
					"color" "Border.Selection"
					"offset" "0 0"
				}
				"2"
				{
					"color" "Border.Dark"
					"offset" "0 0"
				}
			}
		}

		ButtonDepressedBorder
		{
			"inset" "2 1 1 1"
			Left
			{
				"1"
				{
					"color" "Border.Dark"
					"offset" "0 1"
				}
			}

			Right
			{
				"1"
				{
					"color" "Border.Bright"
					"offset" "1 0"
				}
			}

			Top
			{
				"1"
				{
					"color" "Border.Dark"
					"offset" "0 0"
				}
			}

			Bottom
			{
				"1"
				{
					"color" "Border.Bright"
					"offset" "0 0"
				}
			}
		}
	}

	//////////////////////// CUSTOM FONT FILES /////////////////////////////
	//
	// specifies all the custom (non-system) font files that need to be loaded to service the above described fonts
	CustomFontFiles
	{
		"1"		"resource/HALFLIFE2.ttf"
		"2"		"resource/fonts/ProFontWindows.ttf"
		"3"		"resource/fonts/manteka.ttf"
	}
}

// Diamphid (24.03.2013)
// http://steamcommunity.com/id/diamphid/