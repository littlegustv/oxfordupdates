require 'nokogiri'

files = Dir['./medieval-mss/collections/Lyell/*.xml'].reject { |fn| fn.include? "empt" }

files.each do |file|
  doc = Nokogiri::XML(open(file))
  if not doc.at("history")
    puts "No HISTORY tag, skipping:  #{file}"
  elsif doc.search("acquisition").count > 0
    puts "Existing acquisition tag, skipping:  #{file}"
  else
    provenance = doc.create_element('provenance')
    provenance['notBefore'] = '1871'
    provenance['notAfter'] = '1948'
    persName = doc.create_element('persName')
    persName['role'] = 'formerOwner'
    persName['key'] = 'person_64157046'
    persName.content = 'James P. R. Lyell, 1871-1948'
    provenance.add_child(persName)

    doc.at('history').add_child(provenance)

    acquisition = doc.create_element('acquisition')
    acquisition['when'] = '1948'
    acquisition.content = 'Chosen as one of the hundred manuscripts bequeathed to the Bodleian by Lyell in 1948.'

    doc.at('history').add_child(acquisition)
    
    change = doc.create_element('change')
    change["when"] = "2018-04-20"
    change.content = " Updated as part of bulk change to Lyell manuscripts, based on information about the collection"
    change_person = doc.create_element('persName')
    change_person.content = 'Mitch Fraas'
    change.prepend_child(change_person)
    
    doc.at('revisionDesc').prepend_child(change)
  end

  # ... 
  #

  #puts doc.at('history').to_xml
  
  fp = open(file, 'w')
  fp.puts doc.to_xml
  fp.close
end