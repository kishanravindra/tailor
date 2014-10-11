import Foundation

/**
  This method validates a model object by passing it to an arbitrary block.

  The block is responsible for setting errors on the model object if it fails
  the validation. It will be given the key and data used to initialize the
  validator.
  */
public class BlockValidator : Validator {
  /** The block to use to pass the model to for validation. */
  public let block : (Model, String, [String:Any])->()
  
  /**
    This method initializes a block validator with an empty block.
  
    :param: key   The key to validate.
    :param: data  Additional data for the validation.
    */
  public convenience required init(key: String, data: [String:Any]) {
    self.init(key: key, data: data, block: {(Model,String,[String:Any])->() in })
  }
  
  /**
    This method initializes a validator with a block.

    :param: key     The name of the property to validate.
    :param: data    Additional data to give to the block.
    :param: block   The block that will be doing the validation.
    */
  public required init(key: String, data: [String: Any], block: (Model, String, [String:Any])->()) {
    self.block = block
    super.init(key: key, data: data)
  }
  
  /**
    This method runs the block on a model object to validate it.

    :param: model   The model object to validate.
    */
  public override func validate(model: Model) {
    self.block(model, key, data)
  }
}