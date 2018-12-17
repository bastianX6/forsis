require 'fastlane/action'
require_relative '../helper/sonar_test_report_helper'

module Fastlane
  module Actions
    class SonarTestReportAction < Action
      def self.run(params)
        junit_report = params[:junit_report]
        sonarqube_report = params[:sonar_generated_report]
        report = Fastlane::Helper::SonarTestReport.generate(junit_report,sonarqube_report)
        UI.message("The sonar_test_report plugin is working!")
      end

      def self.description
        "This plugin converts junit test reports to gthe sonarqube generic test execution report"
      end

      def self.authors
        ["Azadeh Bagheri"]
      end

      def self.return_value
        # If your method provides a return value, you can describe here what it does
      end

      def self.details
        # Optional:
        "This plugin uses junit test reports generated by fastlane and converts them into the sonarqube generic test execution report"
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(
            key: :junit_report,
            env_name: "SONAR_TEST_REPORT_JUNIT_REPORT",
            description: "The path of the junit test report file that is used to generate the generic test execution file for sonarqube ",
            optional: false,
            type: String,
            verify_block: proc do 
              UI.user_error!("ERROR: junit report not found at path: #{junit_report}") unless File.exist?(junit_report)
            end 
            ),
            FastlaneCore::ConfigItem.new(
              key: :sonar_generated_report,
              env_name: "SONAR_TEST_REPORT_SONAR_GENERATED_REPORT",
              description: "The path of the sonarqube test execution report generated from the junit test report",
              optional: true,
              default_value: 'Test_sonarqube_report.xml',
              type: String
            )
        ]
      end

      def self.is_supported?(platform)
        # Adjust this if your plugin only works for a particular platform (iOS vs. Android, for example)
        # See: https://docs.fastlane.tools/advanced/#control-configuration-by-lane-and-by-platform
        #
         [:ios, :mac].include?(platform)
        true
      end
    end
  end
end
