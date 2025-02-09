MySQL.ready(function()
  local westhaven_mdt_citizens_added = jo.database.addTable('westhaven_mdt_citizens',
  [[id INT NOT NULL AUTO_INCREMENT,
    station VARCHAR(50) NOT NULL DEFAULT '',
    firstname VARCHAR(50) NOT NULL DEFAULT '',
    lastname VARCHAR(50) NOT NULL DEFAULT '',
    alias VARCHAR(50) NOT NULL DEFAULT '',
    age VARCHAR(3) NOT NULL DEFAULT '',
    eyecolor VARCHAR(50) NOT NULL DEFAULT '',
    haircolor VARCHAR(50) NOT NULL DEFAULT '',
    marks TEXT NULL,
    pictureFace VARCHAR(255) NULL,
    pictureSide VARCHAR(255) NULL,
    PRIMARY KEY (id)
  ]])
  local westhaven_mdt_reports_added = jo.database.addTable('westhaven_mdt_reports',
  [[id INT NOT NULL AUTO_INCREMENT,
    citizen INT NOT NULL,
    dateCreated TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    dateUpdated TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    title VARCHAR(100) NOT NULL DEFAULT '',
    summary VARCHAR(100) NOT NULL DEFAULT '',
    content TEXT NULL,
    jail INT NOT NULL DEFAULT 0,
    PRIMARY KEY (`id`)
  ]])
  if not westhaven_mdt_citizens_added and not westhaven_mdt_reports_added then
    gprint('The database is up-to-date.')
  end

  LoadCitizens()
  LoadReports()
  LoadCases()
  LoadSheriffs()
end)

function LoadCitizens()
  MySQL.query('SELECT * FROM westhaven_mdt_citizens', function(result)
    Citizens = result
  end)
end

function LoadReports()
  MySQL.query('SELECT * FROM westhaven_mdt_reports', function(result)
    for _,data in pairs (result) do
      Reports[data.id] = data
    end
  end)
end

function LoadSheriffs()
  MySQL.query('SELECT charidentifier,firstname,lastname,jobgrade FROM characters WHERE job = "sheriff"', function(result)
    for _, data in pairs(result) do
      Sheriffs[_] = {
        id = data.charidentifier,
        firstname = data.firstname,
        lastname = data.lastname,
        rank = data.jobgrade
      }
    end
  end)
 
end

function LoadCases()
  MySQL.query('SELECT * FROM westhaven_mdt_cases', function(result)
    for _,data in pairs (result) do
      Cases[data.id] = data
    end
  end)
end