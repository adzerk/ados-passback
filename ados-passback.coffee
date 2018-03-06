# Usage: passbackToAdzerk({number|array})
window.passbackToAdzerk = (flightId) ->
  isMulti   = flightId instanceof Array
  flightMsg = "for flight #{JSON.stringify(flightId)}"
  flightIds = if isMulti then flightId else [flightId]
  win       = window
  iframes   = []

  # Iterate over this window and parent windows:
  while true
    try
      # If the win window contains the correct adchain execute the passback and
      # return -- we're done.
      for div, flt of (win.ados?.currentPassback||{})
        if flightIds.indexOf(flt) isnt -1
          console.log("Passing back to Adzerk #{flightMsg}...")
          return win["#{if isMulti then 'azk' else 'ados'}_passback"](div, flightId)
    catch
      # The window is in an unfriendly iframe. Add it to the array to send a
      # postMessage later if necessary.
      iframes.push(win)
    break if win is (win = win.parent)

  if iframes.length
    # The adchain was not found in this window or its parents. Send postMessage
    # to each of the unfriendly iframes and assume that one of them will execute
    # the passback (there is no way to know for sure).
    console.log("Sending Adzerk postMessage #{flightMsg}...")
    for iframe in iframes
      iframe.postMessage((if isMulti then {flightIds} else {flightId}), '*')
  else
    # The ad chain was not found in this window or its parents, and there are
    # no unfriendly iframes to send postMessage to, so there are no options
    # left and the passback can't be executed. (This can happen if the adchain
    # is in an iframe that is a child of the window where this is evaluating.)
    console.error("Unable to find an appropriate window for Adzerk passback #{flightMsg}.")
