{pkgs, ...}: {
  home.packages = with pkgs; [waybar];
  home.file = {
    ".config/waybar/config.jsonc".text = ''
      {
      "layer": "top",
      "ouput": "DP-2",
      "height": 15,
      	"modules-left": ["hyprland/workspaces"],
      	"modules-right": [ "pulseaudio", "clock"],
      	"custom/nix": {
      	"format": " ",
      	"tooltip": false,
      	"on-click": "/run/current-system/sw/bin/wofi --show drun"
      	},

      	"hyprland/workspaces": {
      	"format": "{name} {icon}",
      	"tooltip": false,
      	"all-outputs": true,
      	"format-icons": {
      		"active": "",
      		"default": ""
      	},
      	"on-scroll-up": "hyprctl dispatch workspace e-1",
      	"on-scroll-down": "hyprctl dispatch workspace e+1",
      	"on-click": "activate"
      	},

      	"clock": {
      		"format": "  {:%d <small>%a</small> %H:%M}",
      		//"format": " {:%a %b %d %Y | %H:%M}",
      		"format-alt": "  {:%A %B %d %Y (%V) | %r}",
      		"tooltip-format": "<big>{:%Y %B}</big>\n<tt><small>{calendar}</small></tt>",
      		"calendar-weeks-pos": "right",
      		"today-format": "<span color='#f38ba8'><b><u>{}</u></b></span>",
      		"format-calendar": "<span color='#f2cdcd'><b>{}</b></span>",
      		"format-calendar-weeks": "<span color='#94e2d5'><b>W{:%U}</b></span>",
      		"format-calendar-weekdays": "<span color='#f9e2af'><b>{}</b></span>",
      		"interval": 60
      	},

      	"pulseaudio": {
      		// "scroll-step": 1, // %, can be a float
      		"format": "{icon} {volume}%", // {format_source}
      		"format-bluetooth": "{icon} {volume}%", // {format_source}
      		"format-bluetooth-muted": "󰗿", // {format_source}
      		"format-muted": "", // {format_source}
      		"format-source": "{volume}% ",
      		"format-source-muted": "",
      		"format-icons": {
      			"headphone": "󰋋",
      			"headset": "󰋎",
      			"phone": "",
      			"portable": "",
      			"car": " ",
      			"default": [
      				"",
      				"",
      				" "
      			]
      		},
      	},
      }
    '';

    ".config/waybar/style.css".text = ''
      * {
      	font-family: 'M+1Code Nerd Font';
      	font-size: 13px;
      	min-height: 22px;
      }

      window#waybar {
      	background: #262626;
      }

      #workspaces {
      	background-color: #262626;
      	color: #ffffff;
      	margin-top: 0px;
      	margin-right: 15px;
      	padding-top: 0px;
      	padding-left: 10px;
      	padding-right: 10px;
      }

      #custom-nix {
      	background-color: #262626;
      	margin-top: 0px;
      	margin-right: 15px;
      	padding-top: 0px;
      	padding-left: 10px;
      	padding-right: 10px;
      }

      #custom-nix {
      	font-size: 20px;
      	margin-left: 15px;
      	color: #FFFFFF;
      }

      #workspaces button {
      	background: #262626;
      	color: #FFFFFF;
      }

      #pulseaudio, #network, #clock {
      	background-color: #262626;
      	color: #FFFFFF;
      	margin-top: 0px;
      	padding-left: 10px;
      	padding-right: 10px;
      	margin-right: 15px;
      }

      #network {
      	color: #FFFFFF;
      	padding-left: 5px;
      }

      #pulseaudio {
      	color: #FFFFFF;
      	padding-left: 5px;
      }

      #clock {
      	color: #FFFFFF;
      }
    '';
  };
}
