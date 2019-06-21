import {put_flash,clear_flash} from './utils'

class ValidationError extends Error {}

var rangeField = document.querySelector('input[name="ip_pool[ip_range]"]'),
    listField = document.querySelector('textarea[name="ip_pool[list]"]'),
    listCount = document.getElementById('ip-pool-count'),
    netmaskField = document.querySelector('input[name="ip_pool[netmask]"]');

['keyup', 'change'].forEach((eventType) => {
  rangeField.addEventListener(eventType, () => {
    if (rangeField.value === "") {
      rangeField.classList.remove('is-danger')
      return;
    } 

    try {
      var result = parseNetworkInput(rangeField.value)

      if (result.valid !== true) {
        rangeField.classList.add('is-danger')
        return;
      } 

      rangeField.classList.remove('is-danger')

      listField.value = result.list.join("\n")
      listCount.textContent = result.list.length
      netmaskField.value = result.netmask
    } 
    catch (error) {
      if (error instanceof ValidationError) {
        clear_flash('error')
        put_flash('error', error.message)
        rangeField.classList.add('is-danger')
      }
      else {
        console.log(error)
      }
    }
  })
})

var evt = document.createEvent("HTMLEvents");
evt.initEvent("change", false, true);
rangeField.dispatchEvent(evt);

function parseNetworkInput(networkString) {
  networkString = networkString.replace(/ /g, '');

  var networkParts;
  //
  // single ip or CIDR network: 198.13.69.190/32, 192.168.0.1/24
  //
  if (networkParts = networkString.match(/^(\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3})\/(\d{2})/)) {
    validateIp(networkParts[1])
    validateCidrPrefix(networkParts[2])

    if (isNetwork(networkParts[1], networkParts[2])) {
      return {
        valid: true,
        type: 'network',
        cidr: networkParts[2],
        netmask: cidrToNetmask(networkParts[2]),
        address: networkParts[1],
        list: calculateNetwork(networkParts[1], networkParts[2])
      }
    }
    else {
      return {
        valid: true,
        type: 'single',
        cidr: networkParts[2],
        netmask: cidrToNetmask(networkParts[2]),
        address: networkParts[1],
        list: [networkParts[1]]
      }
    }
  }

  //
  // short CIDR network range: 192.168.0.1-16/24
  //
  if (networkParts = networkString.match(/^(\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3})\-(\d{1,3})\/(\d{2})$/)) {
    var firstIp, lastIp

    firstIp = networkParts[1].split('.');
    lastIp = [firstIp[0], firstIp[1], firstIp[2], networkParts[2]];

    if (firstIp[3] >= lastIp[3]) {
      throw new ValidationError('In a short format ' + networkString + ' last IP cannot be smaller then first IP');
    }

    firstIp = firstIp.join('.')
    lastIp = lastIp.join('.')

    validateIp(firstIp)
    validateIp(lastIp)
    validateCidrPrefix(networkParts[3])

    return {
      valid: true,
      type: 'range',
      cidr: networkParts[3],
      netmask: cidrToNetmask(networkParts[3]),
      address: networkParts[1],
      list: calculateNetworkRange(firstIp, lastIp)
    }
  }

  // long CIDR network range: 192.168.0.1-192.168.0.16/24
  if (networkParts = networkString.match(/^(\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3})\-(\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3})\/(\d{2})$/)) {
    validateIp(networkParts[1])
    validateIp(networkParts[2])
    validateCidrPrefix(networkParts[3])

    return {
      valid: true,
      type: 'range',
      cidr: networkParts[3],
      netmask: cidrToNetmask(networkParts[3]),
      address: networkParts[1],
      list: calculateNetworkRange(networkParts[1], networkParts[2])
    }
  }

  return {
    valid: false,
    val: networkString
  };
}

function validateIp(ip) {
  ip.split('.').forEach(function(value) {
    if (value < 0 || value > 255) {
      throw new ValidationError(value + ' is not between 0 and 255');
    }
  })

  if (longToIp(ipToLong(ip)) !== ip) {
    throw new ValidationError(ip + ' is not a valid IP address')
  }
}

function validateCidrPrefix(cidrPrefix) {
  if(isNaN(cidrPrefix)) {
    throw new ValidationError('CIDR prefix must be a number');
  }
  if(cidrPrefix > 32) {
    throw new ValidationError('CIDR prefix must be <= 32 ');
  }
  if(cidrPrefix < 16) {
    throw new ValidationError('CIDR prefix must be >= 16');
  }
}

function calculateNetwork(netwokrString, networkCidr) {
  var networkAddress = (ipToLong(netwokrString)) & ((-1 << (32 - +networkCidr))),
      broadcastAddress = (networkAddress + Math.pow(2, (32 - +networkCidr)) - 1),
      firstIp = longToIp(networkAddress + 1),
      lastIp = longToIp(broadcastAddress - 1)

  return calculateNetworkRange(firstIp, lastIp)
}

function calculateNetworkRange(firstIp, lastIp) {
  var i = 0,
      list = [],
      longFirstIp = ipToLong(firstIp),
      longLastIp = ipToLong(lastIp)

  if (longLastIp - longFirstIp > 65534) {
    throw new ValidationError('Too many IP addresses in range, max 65534 addresses (/16)');
  }

  do {
    list[i++] = longToIp(longFirstIp)
  } while(longFirstIp++ < longLastIp)

  return list
}

function isNetwork(ipAddress, networkCidr) {
  var netmaskString = cidrToNetmask(networkCidr)

  if( ((ipToLong(ipAddress) & ipToLong(netmaskString)) >>> 0) === ipToLong(ipAddress)) {
    return true;
  }

  return false;
}

function cidrToNetmask(cidr) {
  var netmaskBits = parseInt(cidr, 10);
  return longToIp((0xffffffff << (32 - netmaskBits)) >>> 0)
}

function longToIp(long) {
  return [
    (long & (0xff << 24)) >>> 24,
    (long & (0xff << 16)) >>> 16,
    (long & (0xff << 8)) >>> 8,
    long & 0xff
  ].join('.')
}

function ipToLong(ip) {
  var parts = ip.split('.');
  return (parts[0] << 24 | parts[1] << 16 | parts[2] << 8 | parts[3] ) >>> 0
}