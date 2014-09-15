class NabblePostFormat

  def process_nabble_post(raw)
    s = raw.dup
    # Strange encoding characters
    s.gsub!(/=20/, '')
    # Removes truncated lines
    s.gsub!(/=[\n\r]/, '')
    boundaries_found = s.match(/boundary="?([^\n|\r|"]*)/i)
    if boundaries_found
      boundary = boundaries_found.captures[0]
      # The first block surrounded boundary tags is in plain/text
      boundary_regexp = /#{Regexp.escape('--' + boundary)}[\n\r]+(.*)#{Regexp.escape('--' + boundary)}[\n\r]+/im
      email_text_plain_found = s.match(boundary_regexp)
      if email_text_plain_found
        s = email_text_plain_found.captures[0]
      end
      s.gsub!(/^Content-.*:.*[\n\r]?.*\n/i, '')
    end
    # Removes Nabble mailing list email
    s.gsub!(/(^On .*,.*)(<.*@.*nabble\.com>) (wrote:)/mi, "\\1\\3")
    s.gsub!(/(On .*,.*)(<\[hidden email\].*>) (wrote:)/mi, "\\1\\3")
    # Keeps quoted text on one line
    s.gsub!(/(^>.*)=[\n\r]+(.*)/i, '\1\2')
    # Removes Nabble email footer to reply
    s.gsub!(/^>+\s+------------------------------.*naml>[\n\r]+([\n\r]+>[\n\r]+)?/m, '')
    s.gsub!(/^>+\s+If you reply to this email,.*NAML.*(<http:\/\/discuss\.asciidoctor\.org\/.*>)?/m, '')
    s
  end
end
