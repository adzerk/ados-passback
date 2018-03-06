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

  flightIdStr = if isMultipleFlights
                  "flights #{flightId.join ', '}"
                else
                  "flight #{flightId}"

  if adosFound
    console.log "Passing back to Adzerk #{flightIdStr}..."
    passback(divName, flightId)
  else if unfriendlyIframe
    console.log "Sending Adzerk postMessage for #{flightIdStr}..."
    sendPostMessages(window, flightId, isMultipleFlights)
  else
    console.error "Unable to find an appropriate window for Adzerk passback."

