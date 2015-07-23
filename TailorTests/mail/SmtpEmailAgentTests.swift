@testable import Tailor
import TailorTesting

class SmptEmailAgentTests: TailorTestCase {
  func testInitializeWithAllFieldsSetsFields() {
    let agent = SmtpEmailAgent([
      "host": "tailorframe.work",
      "username": "jim",
      "password": "Monkey",
      "ssl": "false",
      "port": "123"
    ])
    assert(agent.host, equals: "tailorframe.work")
    assert(agent.username, equals: "jim")
    assert(agent.password, equals: "Monkey")
    assert(agent.ssl, equals: false)
    assert(agent.port, equals: 123)
  }
  
  func testInitializeWithNoFieldsSetsDefaults() {
    let agent = SmtpEmailAgent([:])
    assert(agent.host, equals: "")
    assert(agent.username, equals: "")
    assert(agent.password, equals: "")
    assert(agent.port, equals: 465)
    assert(agent.ssl, equals: true)
  }
  
  func testInitializeWithNoPortWithoutSslUsesCorrectPort() {
    let agent = SmtpEmailAgent(["ssl": "false"])
    assert(agent.ssl, equals: false)
    assert(agent.port, equals: 587)
  }
  
  func testCurlArgumentsContainsSmtpArguments() {
    let agent = SmtpEmailAgent([
      "host": "tailorframe.work",
      "username": "jim",
      "password": "Monkey",
      "ssl": "false",
      "port": "123"
      ])
    let email = Email(
      from: "jim+mail@tailorframe.work",
      to: "jane@gmail.com",
      subject: "Greetings"
    )
    let arguments = agent.curlArguments(email)
    assert(arguments, equals: [
      "smtps://tailorframe.work",
      "--mail-from",
      "jim+mail@tailorframe.work",
      "--mail-rcpt",
      "jane@gmail.com",
      "--ssl",
      "-u",
      "jim:Monkey",
      "-T",
      "-"
    ])
  }
}