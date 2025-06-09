module Fastlane
  module Actions
    class AddTextOverlayAction < Action
      def self.run(params)
        require 'mini_magick'
        
        UI.message("Adding text overlays to screenshots...")
        
        # Get all screenshots
        screenshots_path = params[:screenshots_path]
        output_path = params[:output_path]
        
        # Create output directory
        FileUtils.mkdir_p(output_path)
        
        # Process each language
        Dir.glob("#{screenshots_path}/*").each do |language_folder|
          next unless File.directory?(language_folder)
          
          language = File.basename(language_folder)
          UI.message("Processing language: #{language}")
          
          # Create language output folder
          language_output = File.join(output_path, language)
          FileUtils.mkdir_p(language_output)
          
          # Get overlay texts for this language
          overlays = params[:overlays][language] || params[:overlays]["default"]
          
          # Process each device folder
          Dir.glob("#{language_folder}/*").each do |device_folder|
            next unless File.directory?(device_folder)
            
            device = File.basename(device_folder)
            device_output = File.join(language_output, device)
            FileUtils.mkdir_p(device_output)
            
            # Process each screenshot
            Dir.glob("#{device_folder}/*.png").each do |screenshot|
              filename = File.basename(screenshot)
              
              # Find matching overlay configuration
              overlay_config = overlays.find { |o| filename.include?(o["filter"]) } if overlays.is_a?(Array)
              next unless overlay_config
              
              UI.message("Adding overlay to #{filename}")
              
              # Open image with MiniMagick
              image = MiniMagick::Image.open(screenshot)
              
              # Add feature badge if specified
              if overlay_config["badge"]
                add_badge(image, overlay_config["badge"], language)
              end
              
              # Add call-to-action if specified
              if overlay_config["cta"]
                add_cta(image, overlay_config["cta"], language)
              end
              
              # Add watermark if specified
              if params[:watermark]
                add_watermark(image, params[:watermark])
              end
              
              # Save processed image
              output_file = File.join(device_output, filename)
              image.write(output_file)
              
              UI.success("Saved: #{output_file}")
            end
          end
        end
        
        UI.success("Text overlays added successfully!")
      end
      
      def self.add_badge(image, badge_config, language)
        image.combine_options do |c|
          # Create rounded rectangle for badge
          c.fill badge_config["background"] || "#F7B6B9"
          c.stroke "none"
          c.draw "roundrectangle 20,20,300,80,10,10"
          
          # Add badge text
          c.fill badge_config["color"] || "#FFFFFF"
          c.font badge_config["font"] || "Helvetica-Bold"
          c.pointsize badge_config["size"] || "30"
          c.gravity "NorthWest"
          text = badge_config["text"][language] || badge_config["text"]["default"] rescue badge_config["text"]
          c.annotate "+40+35", text
        end
      end
      
      def self.add_cta(image, cta_config, language)
        image.combine_options do |c|
          # Add call-to-action button
          button_y = image.height - 120
          
          c.fill cta_config["background"] || "#007AFF"
          c.stroke "none"
          c.draw "roundrectangle 40,#{button_y},340,#{button_y + 60},30,30"
          
          # Add button text
          c.fill cta_config["color"] || "#FFFFFF"
          c.font cta_config["font"] || "Helvetica-Bold"
          c.pointsize cta_config["size"] || "24"
          c.gravity "South"
          text = cta_config["text"][language] || cta_config["text"]["default"] rescue cta_config["text"]
          c.annotate "+0+80", text
        end
      end
      
      def self.add_watermark(image, watermark_config)
        image.combine_options do |c|
          c.fill watermark_config["color"] || "#00000020"
          c.font watermark_config["font"] || "Helvetica"
          c.pointsize watermark_config["size"] || "14"
          c.gravity watermark_config["gravity"] || "SouthEast"
          c.annotate "+10+10", watermark_config["text"] || "TonTon"
        end
      end
      
      def self.description
        "Add localized text overlays to screenshots"
      end
      
      def self.available_options
        [
          FastlaneCore::ConfigItem.new(
            key: :screenshots_path,
            description: "Path to screenshots",
            type: String,
            default_value: "./fastlane/screenshots"
          ),
          FastlaneCore::ConfigItem.new(
            key: :output_path,
            description: "Output path for processed screenshots",
            type: String,
            default_value: "./fastlane/screenshots/overlayed"
          ),
          FastlaneCore::ConfigItem.new(
            key: :overlays,
            description: "Overlay configuration by language",
            type: Hash,
            default_value: {}
          ),
          FastlaneCore::ConfigItem.new(
            key: :watermark,
            description: "Watermark configuration",
            type: Hash,
            optional: true
          )
        ]
      end
      
      def self.is_supported?(platform)
        [:ios, :android].include?(platform)
      end
    end
  end
end