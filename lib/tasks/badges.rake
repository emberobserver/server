# frozen_string_literal: true

namespace :badges do
  task create: :environment do
    score = 10.to_d

    while score >= 0
      score_string = format('%.1f', score)
      File.write(Rails.root.join("app/assets/images/new_badges/#{score_string}.svg"), svg(score))
      score -= 0.1.to_d
    end
  end

  private

  def score_color(score)
    case score
    when 0...1 then '999'
    when 1...3 then 'ff7e63'
    when 3...5 then 'fbab61'
    when 5...7 then 'EDE217'
    when 7...9 then '7ECF27'
    when 9..10 then '28b36d'
    else '999'
    end
  end

  def svg(score)
    %(<svg xmlns="http://www.w3.org/2000/svg" width="162" height="20">
<linearGradient id="b" x2="0" y2="100%">
  <stop offset="0" stop-color="#bbb" stop-opacity=".1"/>
  <stop offset="1" stop-opacity=".1"/>
</linearGradient>
<mask id="a">
  <rect width="162" height="20" rx="3" fill="#fff"/>
</mask>
<g mask="url(#a)">
  <path fill="#555" d="M0 0h102v20H0z"/>
  <path fill="##{score_color(score)}" d="M102 0h60v20h-60z"/>
  <path fill="url(#b)" d="M0 0h162v20H0z"/>
</g>
<g fill="#fff" text-anchor="middle" font-family="DejaVu Sans,Verdana,Geneva,sans-serif" font-size="11">
  <text x="52" y="15" fill="#010101" fill-opacity=".3">ember observer</text>
  <text x="52" y="14">ember observer</text>
  <text x="131" y="15" fill="#010101" fill-opacity=".3">#{score} / 10</text>
  <text x="131" y="14">#{score} / 10</text>
</g>
</svg>
    )
  end
end
