omega = {"cmd", "alt", "ctrl"}
hyper = {"cmd", "alt"}

hs.hotkey.bind(omega, 'r', hs.reload)
hs.hotkey.bind(omega, 'f', maximise)
hs.hotkey.bind(omega, 'v', showClipboard)

hs.hotkey.bind(hyper, "f12", function() hs.application.launchOrFocus("iTerm") end)
hs.hotkey.bind(hyper, "f11", function() hs.application.launchOrFocus("Visual Studio Code") end)
hs.hotkey.bind(hyper, "f10", function() hs.application.launchOrFocus("Slack") end)
--hs.hotkey.bind(hyper, "f9", function() hs.application.launchOrFocus("KeePassX") end)  -- or "Enpass"

hs.hotkey.bind(hyper, "f9", function() hs.application.launchOrFocus("Linphone") end)

hs.hotkey.bind(hyper, "f6", function() hs.application.launchOrFocus("Clementine") end) -- or "Spotify"
hs.hotkey.bind(hyper, "f5", function() hs.application.launchOrFocus("Firefox") end)
