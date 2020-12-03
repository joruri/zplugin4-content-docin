class ErubySourceValidator < ActiveModel::EachValidator
  def validate_each(record, attr, value)
    return if value.blank?

    eruby = Erubis::Eruby.new(value)

    begin
      eruby.evaluate(options[:context])
    rescue Exception => e
      e.message.split(/[\r\n|\r|\n]/).each do |msg|
        record.errors.add(:value, "#{e.class}: #{msg}")
      end
      return
    end

    idents = options[:whitelist_idents] ||
             %w(_buf concat raw escape_html escape_xml html_safe) +
             %w(to_s force_encoding sub gsub include? match scan chomp chop tr) +
             options[:context].to_h.keys.map(&:to_s)
    consts = options[:whitelist_consts] ||
             %w(Erubis XmlHelper)

    lexes = Ripper::Lexer.lex(eruby.src)
    lexes.each do |(row, col), event, token|
      if event == :on_ident && !token.in?(idents)
        record.errors.add(attr, "#{row}行目: #{token}は使用できません。")
      end
      if event == :on_const && !token.in?(consts)
        record.errors.add(attr, "#{row}行目: #{token}は使用できません。")
      end
    end
  end
end
