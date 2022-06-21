const Dolly = artifacts.require("Dolly");
const OriginalMock = artifacts.require("OriginalMock");

const {
  expectEvent,
  expectRevert,
  constants: { ZERO_ADDRESS },
} = require("@openzeppelin/test-helpers");

function dateSeconds(date) {
  return Math.round(date / 1000);
}

contract("Dolly", ([original, owner, collector, malicious, ...accounts]) => {
  describe("clone", () => {
    it("should clone an NFT", async () => {
      // Original collection to clone
      const tokenId = 10;
      const BAYC = await OriginalMock.new();
      await BAYC.mint(tokenId, owner);

      // owner creates a Dolly contract
      const dolly = await Dolly.new({ from: owner });
      await dolly.clone(BAYC.address, tokenId, { from: owner });

      const cloneId = 1;
      assert.equal(
        await BAYC.tokenURI(tokenId),
        await dolly.tokenURI(cloneId) // IDs in Dolly start from 1 and auto increment.
      );
    });

    it("only original token owner can clone", async () => {
      // Original collection to clone
      const tokenId = 10;
      const BAYC = await OriginalMock.new();
      await BAYC.mint(tokenId, owner);

      // malicious creates a Dolly contract
      const dolly = await Dolly.new({ from: malicious });
      await expectRevert(
        dolly.clone(BAYC.address, tokenId, { from: malicious }),
        "Dolly: caller must be owner of the token"
      );
    });

    it("only admin can clone", async () => {
      // Original collection to clone
      const tokenId = 10;
      const BAYC = await OriginalMock.new();
      await BAYC.mint(tokenId, owner);

      // owner creates a Dolly contract
      const dolly = await Dolly.new({ from: owner });
      await expectRevert(
        dolly.clone(BAYC.address, tokenId, { from: malicious }),
        "Admin: caller is not an admin"
      );
    });
  });

  describe("lend", () => {
    it("collector cannot transfer borrowed token", async () => {
      // Original collection to clone
      const tokenId = 10;
      const BAYC = await OriginalMock.new();
      await BAYC.mint(tokenId, owner);

      // owner creates a Dolly contract
      const dolly = await Dolly.new({ from: owner });
      await dolly.clone(BAYC.address, tokenId, { from: owner });

      const cloneId = 1;

      // owner lends the clone
      await dolly.lend(cloneId, collector, 0, { from: owner });

      await expectRevert(
        dolly.safeTransferFrom(collector, malicious, cloneId, {
          from: collector,
        }),
        "Dolly: caller is not allowed to transfer token"
      );
    });
  });

  describe("claim", () => {
    it("owner can claim clone back", async () => {
      // Original collection to clone
      const tokenId = 10;
      const BAYC = await OriginalMock.new();
      await BAYC.mint(tokenId, owner);

      // owner creates a Dolly contract
      const dolly = await Dolly.new({ from: owner });
      await dolly.clone(BAYC.address, tokenId, { from: owner });

      const cloneId = 1;

      // owner lends the clone
      await dolly.lend(cloneId, collector, 0, { from: owner });
      await new Promise((resolve) => setTimeout(resolve));
      // owner claims clone
      await dolly.claim(cloneId, { from: owner });
    });

    it("owner cannot claim if lending is not expired", async () => {
      // Original collection to clone
      const tokenId = 10;
      const BAYC = await OriginalMock.new();
      await BAYC.mint(tokenId, owner);

      // owner creates a Dolly contract
      const dolly = await Dolly.new({ from: owner });
      await dolly.clone(BAYC.address, tokenId, { from: owner });

      const cloneId = 1;

      // owner lends the clone
      await dolly.lend(cloneId, collector, dateSeconds(Date.now() + 1000), {
        from: owner,
      });
      await expectRevert(
        dolly.claim(cloneId, { from: owner }),
        "Dolly: token locked until current lending expiration"
      );
    });
  });

  describe("burn", () => {
    it("when burning original clone tokenURI fails", async () => {
      // Original collection to clone
      const tokenId = 10;
      const BAYC = await OriginalMock.new();
      await BAYC.mint(tokenId, owner);

      // owner creates a Dolly contract
      const dolly = await Dolly.new({ from: owner });
      await dolly.clone(BAYC.address, tokenId, { from: owner });

      // owner burns original
      await BAYC.burn(tokenId);

      const cloneId = 1;
      await expectRevert(dolly.tokenURI(cloneId), "ERC721: invalid token ID");
    });

    it("when burning clone tokenURI fails", async () => {
      // Original collection to clone
      const tokenId = 10;
      const BAYC = await OriginalMock.new();
      await BAYC.mint(tokenId, owner);

      // owner creates a Dolly contract
      const dolly = await Dolly.new({ from: owner });
      await dolly.clone(BAYC.address, tokenId, { from: owner });

      const cloneId = 1;

      // owner burns clone
      await dolly.burn(cloneId, { from: owner });

      await expectRevert(dolly.tokenURI(cloneId), "Dolly: invalid token ID");
    });

    it("owner cannot burn when token is lent", async () => {
      // Original collection to clone
      const tokenId = 10;
      const BAYC = await OriginalMock.new();
      await BAYC.mint(tokenId, owner);

      // owner creates a Dolly contract
      const dolly = await Dolly.new({ from: owner });
      await dolly.clone(BAYC.address, tokenId, { from: owner });

      const cloneId = 1;

      await expectRevert(
        dolly.burn(cloneId, { from: malicious }),
        "Dolly: caller is not allowed to transfer token"
      );

      // owner lents the token
      await dolly.lend(cloneId, collector, 1000, { from: owner });

      // owner tries to burn token while lent
      await expectRevert(
        dolly.burn(cloneId, { from: owner }),
        "Dolly: only owner can burn"
      );
    });
  });

  // ...
});
