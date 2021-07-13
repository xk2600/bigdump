<!---    |         |         |         |         |         |         |      --->

# Leek

Leek is a concept unsubstanticiated, in the same realm and concept as Onion or 
Garlic Routing. At a high-level, Leek combines fragmentation, packet hashing, 
Multiparty XOR and E2E encryption to network cooperatively.

The network and the protocols leveraged by Leek DO NOT intend to provide
End-to-End Encryption. However, when utilized as the underlay for an already
robust End-to-End Encryption implementation, Leek can provide:

 - An incredibly performant transmission path
 
 - A high-degree of anonymnity for transmission of information over a 
   universally untrusted set of participating hosts.
   
Leek accomplishes this feat through separation of duties, transparency in
operation (its function, and operational management are publically viewable),
and through multipath transmission of multiparty multiplexed stream-data.

<!---    |         |         |         |         |         |         |      --->

## Requirements

All design modifications SHOULD hold the following criteria universal:

 - The network MUST be transparent to the packets that are transmitted on it.

 - The network MUST be stateless and be able to make any decision based on
   the contents within the packets traversing the network and it's knowledge
   of it's direct peers.
   
 - Each participant in the network MUST assume all of it's peers are nefarious
   and compromised.
   
 - Each transmission MUST be assumed lost and only the receipt of the original
   header hashed with the originating txToken qualifies an acknolwedgement of
   receipt by the destination party.
   
 - All cryptographic work used to secure a transmission by any MX MUST be
   performed by a non-transmitting MX, except the signing of the packet.
   
   > This means that the prior computed cryptographic keys used to encrypt a
   > a transmission are ALWAYS computed on a different participant than the
   > next-hop for the packet. This separation requirement also means at a bare
   > minimum, 4 nodes contribute to the transmission of a single packet 
   > through any MX: the source MX, the transit MX, the next-hop MX, and the
   > crypto worker MX. Im practice far more MXs will contribute just as a
   > necessity for a functional network and to meet other requirements.
   
 - The resultant circuit-hash should be a cryptographically even distribution
   of packets in the buffer meeting the latency and jitter constraints of the
   network edge to edge.
   
 - The network MUST publish statistic data openly, so any participant can
   query the network to determine reasonable the state of the network.
   
As an aside, the quantity of participants combined with even and economics-
weighted statistical distribution of load is what provides Leek it's potential
as a secure and anonymous transmission network. 

<!---    |         |         |         |         |         |         |      --->

## Multiplexer (MX)

A multiplexer (MX) is any node participating in the network. All MXs participate
in the following roles:

 - **`MX Exchange`** -- Routing Protocol Service advertising hash-path
   reachabililty heuristics and MX state.
   
 - **`Service Lookup Responder`** -- Provides caching recursive service lookup 
   of hash-paths which deliver to a destination leek service.
   
 - **`Cryptographic Proxy`** -- Performs cryptographic work in exchange for
   txTokens. (for lack of a better word, similar to a Crypto Miner)
   
 - **`Cryptographic Broker`** -- Validates and disposes of consumed tokens.
   
 - **`Forward Corrected Fragment Path Buffer`** -- Forwarding engine
   
 - **`Proxy txToken Miner`** -- 
 
 - 
   

<!---    |         |         |         |         |         |         |      --->

## txTokens

txtokens like currency in financial markets enable use of resources through
exchange.

- 128-bit UUID derived from a hash, signed by the private key of a foreign
  MX's Cryptographic Proxy service.

- txToken's are purposefully limited in supply, therfore demand naturally
  increases supply to balance the load. This also means, lack of demand
  decreases supply (invalidating tokens).

- A txToken's value MUST BE constant. One (1) token permits one 
  (1) transmission to one (1) peer multiplexer.
  
- A mathematical model based on the cryptographically validated consumption
  rate of txtokens creates more or less txTokens at txToken destruction.
  
When a multiplexer attaches to the newtork they must perform cryptographic work
on behalf of other multiplexers. This expended work earns txTokens, which
permits transmission.

<!---    |         |         |         |         |         |         |      --->

## Mechanics

 - All parties transmitting on the network MUST also multiplexers (MX)
 
 - The minimum hash-path is three (3) MX peers wide. Two are required as
   transmit the two halves of the muxed paylaod and third for the Forward Error
   Correction payload. 
   
 - As the degree of each MX expands, an MX can choose to increase it's FEC 
   distribution width to accomodate more paths. The benfit 
 
 - Each party must recieve 4 


## Leek Services

 - 128bit UUID hash representing 
 - issued 


## Packet Transmision

1. MX receives a packet
2. MX performs a lookup in it's forwarding-table for the hashed virtual
   interface (HVIF) for the destination leek-service, which returns:
   
     next-hop of destination. 
3. 
