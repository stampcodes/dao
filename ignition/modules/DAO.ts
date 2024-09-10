import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";

const DAOModule = buildModule("DAOModule", (m) => {
  // Indirizzo del token di test ERC-20 su Sepolia
  const tokenAddress = m.getParameter(
    "tokenAddress",
    "0xD4a33860578De61DBAbDc8BFdb98FD742fA7028e"
  );
  const governanceType = m.getParameter("governanceType", 1); // Usa il tipo di governance che preferisci

  // Definisci il contratto DAO e passagli i parametri corretti
  const dao = m.contract("DAO", [tokenAddress, governanceType]);

  return { dao };
});

export default DAOModule;
