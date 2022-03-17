require 'nokogiri'

module Fastlane
  module Helper
    module ForsisHelper
      class Generator
        def self.generate(junit_report_path, sonarqube_report_path)
          junit_file = Nokogiri::XML(File.open(junit_report_path))
          test_file_hash = get_all_paths()
          sonarqube_file = File.open("#{sonarqube_report_path}/Test_sonarqube_report.xml", 'w')
          test_suites = junit_file.xpath("//testsuite")
          builder = Nokogiri::XML::Builder.new do |xml|
            xml.testExecutions({ version: :'1' }) do
              test_suites.each do |test_file|
                file_name = `echo #{test_file["name"]}| cut -d'.' -f 2`.gsub(/\n/, '')
                file_path = test_file_hash[file_name]
                test_cases = []
                test_file.children.each do |child|
                  test_cases << child if child.instance_of?(Nokogiri::XML::Element)
                end
                xml.file({ path: :"#{file_path}" }) do
                  test_cases.each do |test|
                    test_duration = (test["time"].to_f * 1000).round
                    test_failures = []
                    test.children.each do |test_child|
                      test_failures << test_child if test_child.instance_of?(Nokogiri::XML::Element)
                    end
                    xml.testCase({ name: :"#{test["name"]}", duration: :"#{test_duration}" }) do
                      test_failures.each do |failure|
                        failure_type = failure.name
                        failure_message = failure["message"]
                        failure_description = failure.text
                        xml.send(failure_type, failure_description, message: failure_message)
                      end
                    end
                  end
                end
              end
            end
          end
          sonarqube_file.puts(builder.to_xml)
          sonarqube_file.close
        end

        def self.get_test_file_path(file_name)
          `find . -iname "#{file_name}.swift"`.gsub(/\n/, '')
        end

        def self.get_all_paths()
          test_files = []
          test_files += `find . -type f -iname "*Test.swift"`.split
          test_files += `find . -type f -iname "*Tests.swift"`.split
          test_files += `find . -type f -iname "*Spec.swift"`.split
          test_files += `find . -type f -iname "*Specs.swift"`.split
          test_file_hash = Hash.new

          test_files.each { |file|
            file_name = file.split("/").last

            if file_name.end_with?(".swift")
              key = file_name.gsub('.swift', '')
              value = file

              if test_file_hash[key]
                UI.important("Test #{key} exists in two locations: #{test_file_hash[key]} and #{value}")
              else
                test_file_hash[key] = value
              end
            end
          }
          return test_file_hash
        end
      end

      def self.show_message
        UI.message("Hello from the forsis plugin helper!")
      end
    end
  end
end
