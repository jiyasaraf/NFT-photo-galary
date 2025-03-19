module MyModule::NFTPhotographyGallery {
    use aptos_framework::signer;
    use aptos_framework::coin;
    use aptos_framework::aptos_coin::AptosCoin;
    use aptos_framework::table::{self, Table};

    struct NFT has store, key {
        price: u64,
        owner: address,
    }

    struct Gallery has store, key {
        nfts: Table<u64, NFT>,
        next_id: u64,
    }

    public fun mint_nft(creator: &signer, price: u64) acquires Gallery {
        let creator_addr = signer::address_of(creator);
        let gallery = borrow_global_mut<Gallery>(creator_addr);
        let nft = NFT { price, owner: creator_addr };
        table::add(&mut gallery.nfts, gallery.next_id, nft);
        gallery.next_id = gallery.next_id + 1;
    }

    public fun buy_nft(buyer: &signer, creator: address, nft_id: u64) acquires Gallery {
        let gallery = borrow_global_mut<Gallery>(creator);
        let nft = table::borrow_mut<NFT>(&mut gallery.nfts, nft_id);
        let payment = coin::withdraw<AptosCoin>(buyer, nft.price);
        coin::deposit<AptosCoin>(nft.owner, payment);
        nft.owner = signer::address_of(buyer);
    }
}
