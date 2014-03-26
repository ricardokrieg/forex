require 'colorize'

initial_balance = ARGV[0].to_f
daily_percentage = ARGV[1].to_f
years = ARGV[2].to_i
monthly_investiment = ARGV[3].to_f || 0.0

balance = initial_balance
parcial_profit = 0.0
leverage = 100.0
lot_size = balance*leverage/100000

def to_real(value)
    reals, cents = "#{"%.02f" % value}".split('.')

    final_reals = ''
    reals.reverse.split('').each_with_index do |n, index|
        final_reals << '.' if index % 3 == 0 and index != 0
        final_reals << n
    end

    "R$ #{final_reals.reverse},#{cents}"
end

years.times do |year|
    puts "Year #{year+1}".red
    puts "Balance: #{to_real(balance)}".white

    12.times do |month|
        puts "\tMonth #{month+1}".yellow

        balance += monthly_investiment

        20.times do |day|
            daily_profit = balance * (daily_percentage/100)
            parcial_profit += daily_profit

            print "\t(#{"%.02f" % lot_size})\t"

            if (balance+parcial_profit)*(leverage/100000) - lot_size >= 0.01
                balance += parcial_profit
                parcial_profit = 0.0

                lot_size = balance*leverage/100000
            end

            puts "Final Balance: #{to_real(balance)}"
        end
    end
end

puts "Initial Balance: #{to_real(initial_balance)}".white
puts "Daily Percentage: #{"%.02f" % daily_percentage}%".white
puts "Years: #{years}".white
puts "Monthly Investiment: #{to_real(monthly_investiment)}".white
puts "Final Balance: #{to_real(balance)}".white
