Given a service tracker number for a food poisoning case, get the data from the service tracker api and match it with data from the socrata food inspection table

I'm using this with the FastRWeb package.

Usage:
http://174.129.49.183//cgi-bin/R/st-socrata-mashup?st.number=13-00398797
will return json output

http://174.129.49.183//cgi-bin/R/st-socrata-mashup?st.number=13-00398797&json=F
will return human readable output

http://174.129.49.183//cgi-bin/R/st-socrata-mashup?st.number=13-00398797&json=T
will return json output as in the first example

Copyright (c) 2013 Cory Nissen. Released under the MIT License.
