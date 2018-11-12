#!/usr/bin/expect -f
#agent, pair, trust, connect


set time_out 5
set prompt "#"

set mac [lindex $argv 0];

set outputFilename "trustedDevices.txt"

spawn bluetoothctl

expect -re $prompt
send "agent KeyboardOnly\r"
sleep 1

expect -re $prompt
send "pair $mac\r"

expect {
        -re "Failed to pair: org.bluez.Error.AlreadyExists" {
		expect -re $prompt
		send_user "Exiting bluetoothctl, already paired with Device $mac\n"
		send "quit\r"
		expect eof
		exit -1
	}
	
	-re "Failed to pair: org.bluez.Error.AuthenticationFailed" {
                expect -re $prompt
                send_user "Exiting bluetoothct wrong passkey\n"
                send "quit\r"
                expect eof
                exit -1
        }
	-re "Device $mac not available" {
                expect -re $prompt
                send_user "Exiting bluetooth, either wrong Mac adress or Device has not been scanned detected by scan\n"
                send "quit\r"
                expect eof
                exit -1
        }


	-re "Enter passkey" {
		send_user "\nDevice available\n"
		while 1 {
                interact "\r" { send "\r";break}
                }

		exp_continue	
	}
exp_continue
}

expect -re $prompt
send "trust $mac\r"
sleep 1

set outFileId [open $outputFilename "a"] 
puts $outFileId $mac
close $outFileId


expect -re $prompt
send "quit\r"

expect eof


