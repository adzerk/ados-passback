getPassbackContext = (window, isMultipleFlights, divName) ->
  fnName = if isMultipleFlights then 'azk_passback' else 'ados_passback'

  tryParent = (window, divName) =>
    return {adosFound: false} if window == window.parent
    getPassbackContext(window.parent, isMultipleFlights, divName)

  try
    # use the topmost window.divName we can find that has an ados passback
    # chain for the right div in either the same window or the one above it
    divName = window.divName ? divName
    if window[fnName]?
      windowWithPassback = window
      passback = window[fnName]
    else if window.parent[fnName]?
      windowWithPassback = window.parent
      passback = window.parent[fnName]

    thisPassback = windowWithPassback?.ados?.passbacks?[divName]

    unless divName? and passback? and thisPassback?
      return tryParent(window, divName)

    return {adosFound: true, passback, divName}

  catch
    return {unfriendlyIframe: true}

sendPostMessages = (window, flightId, isMultipleFlights) ->
  msg = if isMultipleFlights then {flightIds: flightId} else {flightId}
  window.postMessage(msg, '*')
  unless window == window.parent
    sendPostMessages(window.parent, flightId, isMultipleFlights)

# Sourcing this file and running passbackToAdzerk(12345); will trigger a
# passback to Adzerk flight 12345.
window.passbackToAdzerk = (flightId) ->
  isMultipleFlights = flightId instanceof Array

  {adosFound,
   unfriendlyIframe,
   passback,
   divName} = getPassbackContext(window, isMultipleFlights)

  flightIdAry = if isMultipleFlights then flightId else [flightId]
  flightIdStr = "flight#{if isMultipleFlights then 's' else ''} #{flightIdAry.join(', ')}"

  if adosFound
    console.log "Passing back to Adzerk #{flightIdStr}..."
    passback(divName, flightId)
  else if unfriendlyIframe
    console.log "Sending Adzerk postMessage for #{flightIdStr}..."
    sendPostMessages(window, flightId, isMultipleFlights)
  else
    # It's possible that ados.js was loaded in this window but getPassbackContext()
    # did not return it with the result (for example if this window has ados.js
    # but window.divName is not set -- one way this could happen is if the passback
    # <script> tag containing the call to passbackToAdzerk() is written outside of
    # the iframe in which window.divName was set).
    for div, flt of (window.ados?.currentPassback||{})
      if flightIdAry.indexOf(flt) isnt -1
        console.log "Passing back to Adzerk (from window) #{flightIdStr}..."
        return (window[if isMultipleFlights then 'azk_passback' else 'ados_passback'])(div, flightId)

    console.error "Unable to find an appropriate window for Adzerk passback."

