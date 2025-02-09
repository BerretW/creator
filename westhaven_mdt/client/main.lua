RegisterNetEvent("westhaven_mdt:client:updateMDTData", function(citizens,reports,sheriffs,cases)
  if citizens then
    SendNUIMessage({
      event = "updateCitizens",
      data = {
        citizens = citizens
      }
    })
  end
  if reports then
    SendNUIMessage({
      event = "updateReports",
      data = {
        reports = reports
      }
    })
  end
  if sheriffs then
    SendNUIMessage({
      event = "updateSheriffs",
      data = {
        sheriffs = sheriffs
      }
    })
  end
  if cases then
    SendNUIMessage({
      event = "updateCases",
      data = {
        cases = cases
      }
    })
  end
end)