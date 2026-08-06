#! /bin/sh

: "${LC_ALL:=C.UTF-8}"
: "${LANG:=C.UTF-8}"
export LC_ALL LANG

back_id="0"
back_label="← Back"
usage_dir="${XDG_DATA_HOME:-$HOME/.local/share}/RofiScripts/Emojis"
usage_file="$usage_dir/usage.log"

mkdir -p "$usage_dir"
touch "$usage_file"

open_launcher() {
	setsid -f "$HOME/.config/RofiScripts/Launcher/Launcher.sh" >/dev/null 2>&1
}

build_menu() {
	printf "%s\t%s\n" "$back_id" "$back_label"
	cat <<'EOF'
1	😀 grinning face
2	😃 grinning face with big eyes
3	😄 grinning face with smiling eyes
4	😁 beaming face with smiling eyes
5	😂 face with tears of joy
6	🤣 rolling on the floor laughing
7	😊 smiling face with smiling eyes
8	😇 smiling face with halo
9	🙂 slightly smiling face
10	🙃 upside-down face
11	😉 winking face
12	😍 smiling face with heart-eyes
13	😘 face blowing a kiss
14	😎 smiling face with sunglasses
15	🤔 thinking face
16	😴 sleeping face
17	😢 crying face
18	😭 loudly crying face
19	😡 pouting face
20	👍 thumbs up
21	👎 thumbs down
22	👏 clapping hands
23	🙏 folded hands
24	🤝 handshake
25	💪 flexed biceps
26	👋 waving hand
27	👌 OK hand
28	✌ victory hand
29	🤞 crossed fingers
30	🤘 sign of the horns
31	💖 sparkling heart
32	💘 heart with arrow
33	💝 heart with ribbon
34	❤️ red heart
35	🧡 orange heart
36	💛 yellow heart
37	💚 green heart
38	💙 blue heart
39	💜 purple heart
40	🖤 black heart
41	🤍 white heart
42	💔 broken heart
43	✨ sparkles
44	🔥 fire
45	⭐ star
46	🌟 glowing star
47	💯 hundred points
48	✅ check mark
49	❌ cross mark
50	⚠ warning
51	ℹ information
52	💡 light bulb
53	🔔 bell
54	🔒 lock
55	🔑 key
56	🗑 trash can
57	📎 paperclip
58	📌 pushpin
59	📝 memo
60	📷 camera
61	🎵 musical note
62	🎉 party popper
63	🌈 rainbow
64	☀ sun
65	🌙 crescent moon
66	☁ cloud
67	🌧 cloud with rain
68	❄ snowflake
69	🌸 cherry blossom
70	🌻 sunflower
71	🍕 pizza
72	☕ hot beverage
73	🍺 beer mug
74	🚀 rocket
75	🎮 video game
76	💻 laptop
77	📚 books
78	🛠 hammer and wrench
79	⚙ gear
80	⌛ hourglass done
81	⏳ hourglass not done
82	🚫 prohibited
83	🔋 battery
84	📶 antenna bars
85	🌍 globe showing Europe-Africa
86	🧠 brain
87	🧩 puzzle piece
88	🎯 direct hit
89	🧭 compass
90	🧪 test tube
91	🥳 partying face
92	😌 relieved face
93	😔 pensive face
94	😕 confused face
95	🙁 slightly frowning face
96	☹ frowning face
97	😤 face with steam from nose
98	🤯 exploding head
99	😱 face screaming in fear
100	🤗 smiling face with open hands
101	🫡 saluting face
102	🫠 melting face
103	🤠 cowboy hat face
104	🥶 cold face
105	🥵 hot face
106	🥺 pleading face
107	😈 smiling face with horns
108	👀 eyes
109	🫶 heart hands
110	🤲 palms up together
111	🫱 rightwards hand
112	🫲 leftwards hand
113	🖐 hand with fingers splayed
114	🤙 call me hand
115	🫰 hand with index finger and thumb crossed
116	🤚 raised back of hand
117	✍ writing hand
118	🫵 index pointing at the viewer
119	🫳 palm down hand
120	🫴 palm up hand
121	💌 love letter
122	💞 revolving hearts
123	💓 beating heart
124	💗 growing heart
125	💥 collision
126	💫 dizzy
127	💢 anger symbol
128	💦 sweat droplets
129	💤 zz
130	💬 speech balloon
131	🗨 left speech bubble
132	🗯 right anger bubble
133	💭 thought balloon
134	🚦 vertical traffic light
135	🚗 automobile
136	🚕 taxi
137	🚌 bus
138	🚎 trolleybus
139	🚓 police car
140	🚑 ambulance
141	🚒 fire engine
142	🚜 tractor
143	🛵 motor scooter
144	🏍 motorcycle
145	🚲 bicycle
146	🛹 skateboard
147	🧳 luggage
148	📱 mobile phone
149	⌨ keyboard
150	🖱 computer mouse
151	🖨 printer
152	🧵 thread
153	🪡 sewing needle
154	🪛 screwdriver
155	🔧 wrench
156	🔨 hammer
157	🪓 axe
158	🧰 toolbox
159	🪣 bucket
160	🧹 broom
161	🧽 sponge
162	🧯 fire extinguisher
163	📦 package
164	📁 folder
165	📂 open file folder
166	📅 calendar
167	🗓 spiral calendar
168	🕒 three o'clock
169	⏱ stopwatch
170	⏲ timer clock
171	🧿 nazar amulet
172	🪬 hamsa
173	🔭 telescope
174	📡 satellite antenna
175	🧫 petri dish
176	🧬 dna
177	🦠 microbe
178	🧱 brick
179	🍏 green apple
180	🍎 red apple
181	🍊 tangerine
182	🍌 banana
183	🍇 grapes
184	🍓 strawberry
185	🍒 cherries
186	🍑 peach
187	🍍 pineapple
188	🥐 croissant
189	🥨 pretzel
190	🍔 hamburger
191	🍟 french fries
192	🍣 sushi
193	🍜 steaming bowl
194	🍩 doughnut
195	🍪 cookie
196	🧁 cupcake
197	🍿 popcorn
198	🍫 chocolate bar
199	🥤 cup with straw
200	🧃 beverage box
201	🤡 clown face
202	🤮 face vomiting
203	💩 pile of poo
EOF
}

menu="$(
	build_menu |
	awk -F "$(printf '\t')" '
		NR == FNR {
			usage[$0]++
			next
		}

		{
			item_id = $1
			item_label = $2

			if (item_id == 0) {
				next
			}

			split(item_label, parts, /[[:space:]]+/)
			emoji = parts[1]
			count = (emoji in usage) ? usage[emoji] : 0
			printf "%s\t%s\t%s\n", count, item_id, item_label
		}
	' "$usage_file" - |
	sort -t "$(printf '\t')" -k1,1nr -k2,2n |
	cut -f2-
)"
menu="$(printf "%s\t%s\n%s" "$back_id" "$back_label" "$menu")"
selected_row=1

chosen_index=$(
	{
		printf "%s" "$menu"
	} | rofi -dmenu -format i -selected-row "$selected_row" -display-columns 2 -config "$HOME/.config/RofiScripts/Emojis/E.rasi" -kb-move-char-back "" -kb-move-char-forward "" -kb-custom-1 "Left" -kb-accept-entry "Return,KP_Enter,Right"
)
rc=$?

if [ "$rc" -eq 10 ]; then
	open_launcher
	exit 0
fi

[ -z "$chosen_index" ] && exit 0

case "$chosen_index" in
	*[!0-9]*)
		exit 1
		;;
esac

if [ "$chosen_index" -eq 0 ]; then
	open_launcher
	exit 0
fi

line_number=$((chosen_index + 1))
chosen_line="$(printf "%s" "$menu" | sed -n "${line_number}p")"
[ -z "$chosen_line" ] && exit 0

emoji="$(printf "%s" "$chosen_line" | cut -f2 | cut -d' ' -f1)"
[ -z "$emoji" ] && exit 0

printf "%s" "$emoji" | wl-copy
if wtype_bin="$(command -v wtype 2>/dev/null)"; then
	"$wtype_bin" "$emoji"
else
	hyprctl notify 4000 2 "Emoji picker" "wtype is not installed, copied to clipboard only"
fi
printf '%s\n' "$emoji" >> "$usage_file"
