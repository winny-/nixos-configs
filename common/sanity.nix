{ config, ... }:
{
  # Thanks to https://srid.ca/block-social-media
  networking.extraHosts = ''
    127.0.0.2 twitter.com  # Undesirable time sink, avoid.
    127.0.0.2 mobile.twitter.com
    127.0.0.2 nixos.wiki  # See https://nixos.wiki/wiki/User:Winny for explaination.
                          # This wiki is effectively dead.
    127.0.0.2 picknsave.com  # Undesirable company, avoid.
    127.0.0.2 news.ycombinator.com  # Time waster, no benefit of using my time
                                    # reading this content.
  '';
}
