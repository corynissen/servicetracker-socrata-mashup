Given a service tracker number for a food poisoning case, get the data from the service tracker api and match it with data from the socrata food inspection table

I'm using this with the FastRWeb package.

Usage:
http://some-ip-or-url-here/cgi-bin/R/st-socrata-mashup?st.number=13-00398797
will return json output

http://some-ip-or-url-here/cgi-bin/R/st-socrata-mashup?st.number=13-00398797&json=F
will return human readable output

http://some-ip-or-url-here/cgi-bin/R/st-socrata-mashup?st.number=13-00398797&json=T
will return json output as in the first example
