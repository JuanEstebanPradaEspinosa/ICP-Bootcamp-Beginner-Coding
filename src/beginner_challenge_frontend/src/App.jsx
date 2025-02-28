import { useState } from "react";
import IdentityLogin from "./components/IdentityLogin";

function App() {
  const [backendActor, setBackendActor] = useState();
  const [userId, setUserId] = useState();
  const [userName, setUserName] = useState();
  const [results, setResults] = useState();

  const handleGetProfile = () => {
    backendActor.getUserProfile().then((response) => {
      if (response.ok) {
        setUserId(response.ok.id.toString());
        setUserName(response.ok.name);
      } else if (response.err) {
        setUserId(response.err);
      } else {
        console.error(response);
        setUserId("Unexpected error, check the console");
      }
    });
  };

  const handleSubmitUserProfile = (event) => {
    event.preventDefault();
    const name = event.target.elements.name.value;
    backendActor.setUserProfile(name).then((response) => {
      if (response.ok) {
        setUserId(response.ok.id.toString());
        setUserName(response.ok.name);
      } else if (response.err) {
        setUserId(response.err);
      } else {
        console.error(response);
        setUserId("Unexpected error, check the console");
      }
    });
    return false;
  };

  const handleAddResult = (event) => {
    event.preventDefault();
    const result = event.target.elements.result.value;
    backendActor.addUserResult(result).then((response) => {
      if (response.ok) {
        setUserId(response.ok.id.toString());
        setResults(response.ok.results);
      } else if (response.err) {
        setUserId(response.err);
      } else {
        console.error(response);
        setUserId("Unexpected error, check the console");
      }
    });
    return false;
  };

  const handleGetResults = () => {
    backendActor.getUserResults().then((response) => {
      if (response.ok) {
        setUserId(response.ok.id.toString());
        setResults(response.ok.results);
      } else if (response.err) {
        setUserId(response.err);
      } else {
        console.error(response);
        setUserId("Unexpected error, check the console");
      }
    });
  };

  return (
    <main>
      <img src="/logo2.svg" alt="DFINITY logo" />
      <br />
      <br />
      <h1>Welcome to ICP BOOTCAMP!</h1>
      <br />
      <br />
      {!backendActor && (
        <section id="identity-section">
          <IdentityLogin setBackendActor={setBackendActor}></IdentityLogin>
        </section>
      )}
      {backendActor && (
        <>
          <section>
            <h2>Profile management</h2>
            <form action="#" onSubmit={handleSubmitUserProfile}>
              <label htmlFor="name">Enter your name: &nbsp;</label>
              <input id="name" alt="Name" type="text" />
              <button type="submit">Save</button>
            </form>
            <button onClick={handleGetProfile}>Get Profile</button>
            {userId && <p className="response">User ID: {userId}</p>}
            {userName && <p className="response">User Name: {userName}</p>}
          </section>

          <section>
            <h2>Result management</h2>
            <form action="#" onSubmit={handleAddResult}>
              <label htmlFor="result">Enter your result: &nbsp;</label>
              <input id="result" alt="Result" type="text" />
              <button type="submit">Add Result</button>
            </form>
            <button onClick={handleGetResults}>Get Results</button>
            {results && (
              <ul>
                {results.map((result, index) => (
                  <li key={index}>{result}</li>
                ))}
              </ul>
            )}
          </section>
        </>
      )}
    </main>
  );
}

export default App;
