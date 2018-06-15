require 'nokogiri'

# change to the correct path to the desired collection xml files...
#files = Dir['/home/hellerb/Projects/medieval-mss/collections/Lyell/*.xml'].reject { |fn| fn.include? "empt" }

files = Dir['/home/hellerb/Projects/medieval-mss/collections/Lyell/*.xml'].reject { |fn| fn.include? "empt" }

files.each do |file|
  doc = Nokogiri::XML(open(file))

  puts "#{file} >>>     msParts: #{doc.search("msPart").count}, msParts WITH history: #{doc.css('msPart > history').count}, msDesc WITH history: #{doc.css('msDesc > history').count}"

  if (history = doc.css("msDesc > history").first)
    # pass
  else
    history = doc.create_element("history")
    doc.css("msDesc > additional").before(history)
    puts "Adding new HISTORY tag for: #{file}"
  end

  if history.search("acquisition").count > 0
    puts "Existing acquisition tag, skipping:  #{file}"    
  else
    provenance = doc.create_element('provenance')
    provenance['notBefore'] = '1871'
    provenance['notAfter'] = '1948'
    provenance['resp'] = '#MMM'
    persName = doc.create_element('persName')
    persName['role'] = 'formerOwner'
    persName['key'] = 'person_64157046'
    persName.content = 'James P. R. Lyell, 1871-1948'
    provenance.add_child(persName)

    doc.at('history').add_child(provenance)

    acquisition = doc.create_element('acquisition')
    acquisition['when'] = '1948'
    acquisition['resp'] = '#MMM'
    acquisition.content = 'Chosen as one of the hundred manuscripts bequeathed to the Bodleian by Lyell in 1948.'

    doc.at('history').add_child(acquisition)
    
    change = doc.create_element('change')
    change["when"] = "2018-06-15"
    change["xml:id"] = "MMM"
    change.inner_html = %q(
      Provenance and acquisition information added using <ref target=”https://github.com/littlegustv/oxfordupdates/blob/master/test_case_for_oxford_prov.rb”>https://github.com/littlegustv/oxfordupdates/blob/master/test_case_for_oxford_prov.rb</ref>
      in collaboration with the <ref target=”http://mappingmanuscriptmigrations.org/”>Mapping Manuscript Migrations</ref> project.'
    )
    change_person = doc.create_element('persName')
    change_person.content = 'Mitch Fraas/Mapping Manuscript Migrations'
    change.prepend_child(change_person)
    
    doc.at('revisionDesc').prepend_child(change)
  end

  fp = open(file, 'w')
  fp.puts doc.to_xml
  fp.close
end