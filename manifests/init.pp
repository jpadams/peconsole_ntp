# This is a wrapper for puppetlabs-ntp which allows the 'servers'
# parameter to be properly handled due to lack of support for array,
# hash, boolean types for class parameters in the PE 3.0, 3.1 console.
#
# This class wraps ntp, takes a comma-separted string of ntp servers, creates
# an array and passes this array as a parameter to the ntp class.
# It has future support for arrays in the console built in.
# Support for arrays, hashes, booleans has been completed and will be
# in PE 3.2 (likely Q1 2014), but this can serve as a stopgap in PE 3.0, 3.1.
#
# This was designed for the following ntp module on the forge:
# name      'puppetlabs-ntp'
# forge-url 'http://forge.puppetlabs.com/puppetlabs/ntp'


class peconsole_ntp(
  # we want to be able to define the server list in the PE console
  $servers = undef
) {
  # to future-proof this module for when PE Console supports array params
  if is_array($servers) {
    $servers_array = $servers
  # to work around lack of array param support by accepting a
  # comma-separated string of servers
  } elsif is_string($servers) {
    if strip($servers) == '' {
      $servers_array = undef
    } else {
      $servers_array = split($servers, ',')
    }
  } else {
    fail('only array or string values are acceptable for servers parameter')
  }
  # if no valid server list, defer to defaults in ntp
  if $servers_array == undef {
    include ::ntp
  # otherwise validate, normalize, and pass our array of servers
  } else {
    # remove whitespace & deduplicate array entries including empty entries
    $final_servers_array = delete(unique(strip($servers_array)), '')
    # make sure we ended up with a valid array
    validate_array($final_servers_array)
    #pass the array of ntp servers to ntp
    class { '::ntp':
      servers => $final_servers_array,
    }
  }
}
