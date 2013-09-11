#3> <> prov:specializationOf <https://github.com/timrdf/prizms/blob/master/bin/dataset/pr-neighborlod/unknown-domain.awk> .

{
   if($0 ~ /# Namespace filters:/) {
      print $0; 
      if( length(ns1) > 0 && ns1 ~ /^http/ ) {
         printf("  filter(!regex(str(?s),'^%s'))\n",ns1)
      }
      if( length(ns2) > 0 && ns2 ~ /^http/ ) {
         printf("  filter(!regex(str(?s),'^%s'))\n",ns2)
      }
   }else {
      print
   }
}
